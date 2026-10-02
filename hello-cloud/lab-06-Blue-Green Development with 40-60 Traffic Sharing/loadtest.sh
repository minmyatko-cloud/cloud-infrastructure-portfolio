#!/bin/bash
# ALB weighted routing test
# Sends N requests to an ALB, then reads RequestCount per target group
# from CloudWatch and compares the split with the configured weights.
#
# Requirements: aws cli (configured), curl, awk, xargs
# IAM permissions: elasticloadbalancing:DescribeLoadBalancers,
#                  elasticloadbalancing:DescribeTargetGroups,
#                  cloudwatch:GetMetricStatistics

# ---------- EDIT THESE ----------
# You can set these as environment variables when running the script
# (no file editing needed), e.g.:
#   ALB_NAME=my-alb ALB_URL=dashboard-alb-1404806516.ap-southeast-1.elb.amazonaws.com/ ./loadtest.sh
REGION="${REGION:-ap-southeast-1}"
ALB_NAME="${ALB_NAME:-dashboard-alb}"        # load balancer NAME, not the DNS name
ALB_URL="${ALB_URL:-http://dashboard-alb-1404806516.ap-southeast-1.elb.amazonaws.com/}"

TG1="${TG1:-dashboard-alb}"                # target group names
W1="${W1:-3}"                                # and their weights
TG2="${TG2:-dashboard-alb-v2}"
W2="${W2:-2}"

TOTAL="${TOTAL:-1000}"       # number of requests to send
PARALLEL="${PARALLEL:-10}"   # concurrent curl workers (1 = sequential)
WAIT="${WAIT:-150}"          # seconds to wait for CloudWatch to publish metrics
# --------------------------------

if [[ "$ALB_NAME" == "your-alb-name" || "$ALB_URL" == *"your-alb-dns-name"* ]]; then
  echo "Set ALB_NAME and ALB_URL first (as environment variables or in this file)."
  exit 1
fi

for cmd in aws curl awk xargs; do
  command -v "$cmd" >/dev/null || { echo "Missing required command: $cmd"; exit 1; }
done

# CloudWatch dimension values are the tail of each ARN
LB_DIM=$(aws elbv2 describe-load-balancers --names "$ALB_NAME" --region "$REGION" \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text | sed 's/.*:loadbalancer\///')
TG1_DIM=$(aws elbv2 describe-target-groups --names "$TG1" --region "$REGION" \
  --query 'TargetGroups[0].TargetGroupArn' --output text | sed 's/.*://')
TG2_DIM=$(aws elbv2 describe-target-groups --names "$TG2" --region "$REGION" \
  --query 'TargetGroups[0].TargetGroupArn' --output text | sed 's/.*://')

if [[ -z "$LB_DIM" || "$LB_DIM" == "None" || -z "$TG1_DIM" || "$TG1_DIM" == "None" || -z "$TG2_DIM" || "$TG2_DIM" == "None" ]]; then
  echo "Could not resolve the load balancer or target groups. Check names, region and credentials."
  exit 1
fi

SUM_W=$((W1 + W2))

echo "=========================================="
echo " ALB Weighted Routing Test"
echo "=========================================="
echo
echo "Configured weights:"
awk -v n="$TG1" -v w="$W1" -v s="$SUM_W" 'BEGIN{printf "  %-36s = %d (%.0f%%)\n", n, w, w/s*100}'
awk -v n="$TG2" -v w="$W2" -v s="$SUM_W" 'BEGIN{printf "  %-36s = %d (%.0f%%)\n", n, w, w/s*100}'
echo
echo "Sending $TOTAL requests to $ALB_URL ..."

START=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Each curl call opens a new connection, so the ALB picks a target group per request.
# The output below is the HTTP status code distribution (expect all 200s).
seq 1 "$TOTAL" | xargs -P "$PARALLEL" -I{} \
  curl -s -o /dev/null -w "%{http_code}\n" --max-time 10 "$ALB_URL" | sort | uniq -c | \
  awk '{printf "  HTTP %s: %s responses\n", $2, $1}'

echo
echo "Finished sending requests."
echo "Waiting $WAIT seconds for CloudWatch metrics..."
sleep "$WAIT"

END=$(date -u +%Y-%m-%dT%H:%M:%SZ)

get_count() {
  aws cloudwatch get-metric-statistics --region "$REGION" \
    --namespace AWS/ApplicationELB --metric-name RequestCount \
    --dimensions Name=LoadBalancer,Value="$LB_DIM" Name=TargetGroup,Value="$1" \
    --start-time "$START" --end-time "$END" --period 60 --statistics Sum \
    --query 'sum(Datapoints[].Sum)' --output text
}

echo "Reading CloudWatch..."
C1=$(get_count "$TG1_DIM")
C2=$(get_count "$TG2_DIM")
SEEN=$(awk -v a="$C1" -v b="$C2" 'BEGIN{print a+b}')

row() {  # name count weight
  awk -v name="$1" -v n="$2" -v w="$3" -v s="$SUM_W" -v t="$SEEN" \
    'BEGIN{printf "%-38s %10.0f %9.1f%% %9.1f%%\n", name, n, (t>0 ? n/t*100 : 0), w/s*100}'
}

echo
echo "=========================================="
echo " Results"
echo "=========================================="
printf "%-38s %10s %10s %10s\n" "Target Group" "Requests" "Actual" "Expected"
echo "------------------------------------------------------------------"
row "$TG1" "$C1" "$W1"
row "$TG2" "$C2" "$W2"
echo "------------------------------------------------------------------"
printf "%-38s %10.0f\n" "TOTAL" "$SEEN"

if awk -v t="$SEEN" -v x="$TOTAL" 'BEGIN{exit !(t < x*0.95)}'; then
  echo
  echo "Note: CloudWatch shows fewer requests than sent. Metrics may still be"
  echo "publishing (increase WAIT), or some requests failed (see HTTP codes above)."
fi
