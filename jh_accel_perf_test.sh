ssl@cse1:~/jh_spdk/accelTest/spdk/build/examples$ cat jh_accel_perf_test.sh
#!/bin/bash

# 실험 결과 저장 파일
ACCEL_RESULT_FILE="accel_perf_results.log"

# 로그 파일 초기화
echo "===================================" > $ACCEL_RESULT_FILE
echo "SPDK accel_perf Performance Test" >> $ACCEL_RESULT_FILE
echo "실행 시간: $(date)" >> $ACCEL_RESULT_FILE
echo "===================================" >> $ACCEL_RESULT_FILE
echo "" >> $ACCEL_RESULT_FILE

# 기본 설정값
DEFAULT_TIME=5
DEFAULT_TRANSFER_SIZE=4096
DEFAULT_QDEPTH=32
DEFAULT_THREADS=1

# 테스트할 변수 리스트
QUEUE_DEPTH_LIST=(16 32 64 128)
THREADS_LIST=(1 2 4 8)
TRANSFER_SIZE_LIST=(4096 8192 16384 32768)
RUN_TIME_LIST=(2 5 10)

run_test() {
    DESC=$1
    CMD=$2

    echo "==============================" >> $ACCEL_RESULT_FILE
    echo "[JoonHee] Test : $DESC" >> $ACCEL_RESULT_FILE
    echo "[JoonHee] Command : $CMD" >> $ACCEL_RESULT_FILE
    echo "------------------------------" >> $ACCEL_RESULT_FILE

    eval $CMD >> $ACCEL_RESULT_FILE 2>&1

    echo "[JoonHee] Done !!" >> $ACCEL_RESULT_FILE
}

# ==============================
# 큐 깊이 변화 실험
echo "=== 큐 깊이 변화 실험 ===" | tee -a $ACCEL_RESULT_FILE
for QDEPTH in "${QUEUE_DEPTH_LIST[@]}"; do
    run_test "Queue Depth: $QDEPTH" "sudo ./accel_perf -q $QDEPTH -T $DEFAULT_THREADS -s $DEFAULT_TRANSFER_SIZE -w copy -M software"
done

# ==============================
# 스레드 개수 변화 실험
echo "" | tee -a $ACCEL_RESULT_FILE
echo "=== 스레드 개수 변화 실험 ===" | tee -a $ACCEL_RESULT_FILE
for THREADS in "${THREADS_LIST[@]}"; do
    run_test "Threads: $THREADS" "sudo ./accel_perf -q $DEFAULT_QDEPTH -T $THREADS -s $DEFAULT_TRANSFER_SIZE -w copy -M software"
done

# ==============================
# 전송 크기 변화 실험
echo "" | tee -a $ACCEL_RESULT_FILE
echo "=== 전송 크기 변화 실험 ===" | tee -a $ACCEL_RESULT_FILE
for SIZE in "${TRANSFER_SIZE_LIST[@]}"; do
    run_test "Transfer Size: $SIZE" "sudo ./accel_perf -q $DEFAULT_QDEPTH -T $DEFAULT_THREADS -s $SIZE -w copy -M software"
done

# ==============================
# 실행 시간 변화 실험
echo "" | tee -a $ACCEL_RESULT_FILE
echo "=== 실행 시간 변화 실험 ===" | tee -a $ACCEL_RESULT_FILE
for TIME in "${RUN_TIME_LIST[@]}"; do
    run_test "Execution Time: $TIME sec" "sudo ./accel_perf -q $DEFAULT_QDEPTH -T $DEFAULT_THREADS -s $DEFAULT_TRANSFER_SIZE -w copy -M software -t $TIME"
done

echo "=== 모든 실험 완료 ===" | tee -a $ACCEL_RESULT_FILE
echo "실험 종료 시간: $(date)" | tee -a $ACCEL_RESULT_FILE
