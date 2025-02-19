ssl@cse1:~/jh_spdk/accelTest/spdk/build/examples$ cat jh_ioat_perf_test.sh
#!/bin/bash

# 실험 결과 저장 파일
IOAT_RESULT_FILE="ioat_perf_results.log"

# 로그 파일 초기화
echo "===================================" > $IOAT_RESULT_FILE
echo "SPDK ioat_perf Performance Test" >> $IOAT_RESULT_FILE
echo "실행 시간: $(date)" >> $IOAT_RESULT_FILE
echo "===================================" >> $IOAT_RESULT_FILE
echo "" >> $IOAT_RESULT_FILE

# 기본 설정값
DEFAULT_TIME=5
DEFAULT_TRANSFER_SIZE=4096
DEFAULT_QDEPTH=32
DEFAULT_CHANNELS=1

# 테스트할 변수 리스트
QUEUE_DEPTH_LIST=(16 32 64 128)
CHANNEL_LIST=(1 2 4 8 16)
TRANSFER_SIZE_LIST=(4096 8192 16384 32768)
RUN_TIME_LIST=(2 5 10)

run_test() {
    DESC=$1
    CMD=$2

    echo "==============================" >> $IOAT_RESULT_FILE
    echo "[JoonHee] Test : $DESC" >> $IOAT_RESULT_FILE
    echo "[JoonHee] Command : $CMD" >> $IOAT_RESULT_FILE
    echo "------------------------------" >> $IOAT_RESULT_FILE

    eval $CMD >> $IOAT_RESULT_FILE 2>&1

    echo "[JoonHee] Done !!" >> $IOAT_RESULT_FILE
}

# ==============================
# 큐 깊이 변화 실험
echo "=== 큐 깊이 변화 실험 ===" | tee -a $IOAT_RESULT_FILE
for QDEPTH in "${QUEUE_DEPTH_LIST[@]}"; do
    run_test "Queue Depth: $QDEPTH" "sudo ./ioat_perf -q $QDEPTH -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE"
done

# ==============================
# 채널 개수 변화 실험
echo "" | tee -a $IOAT_RESULT_FILE
echo "=== 채널 개수 변화 실험 ===" | tee -a $IOAT_RESULT_FILE
for CHANNELS in "${CHANNEL_LIST[@]}"; do
    run_test "Channels: $CHANNELS" "sudo ./ioat_perf -c 0x1 -n $CHANNELS -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE"
done

# ==============================
# 전송 크기 변화 실험
echo "" | tee -a $IOAT_RESULT_FILE
echo "=== 전송 크기 변화 실험 ===" | tee -a $IOAT_RESULT_FILE
for SIZE in "${TRANSFER_SIZE_LIST[@]}"; do
    run_test "Transfer Size: $SIZE" "sudo ./ioat_perf -q $DEFAULT_QDEPTH -t $DEFAULT_TIME -o $SIZE"
done

# ==============================
# 실행 시간 변화 실험
echo "" | tee -a $IOAT_RESULT_FILE
echo "=== 실행 시간 변화 실험 ===" | tee -a $IOAT_RESULT_FILE
for TIME in "${RUN_TIME_LIST[@]}"; do
    run_test "Execution Time: $TIME sec" "sudo ./ioat_perf -q $DEFAULT_QDEPTH -t $TIME -o $DEFAULT_TRANSFER_SIZE"
done

echo "=== 모든 실험 완료 ===" | tee -a $IOAT_RESULT_FILE
echo "실험 종료 시간: $(date)" | tee -a $IOAT_RESULT_FILE
