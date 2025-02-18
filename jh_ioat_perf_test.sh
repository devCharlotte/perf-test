ssl@cse1:~/jh_spdk/accelTest/spdk/build/examples$ cat jh_ioat_perf_test.sh
#!/bin/bash

# 실험 결과 저장 파일
RESULT_FILE="ioat_perf_results.log"

# 로그 파일 초기화
echo "===================================" > $RESULT_FILE
echo "SPDK ioat_perf Performance Test by JoonHee" >> $RESULT_FILE
echo "실행 시간: $(date)" >> $RESULT_FILE
echo "===================================" >> $RESULT_FILE
echo "" >> $RESULT_FILE

# 실행 시간(초)
DEFAULT_TIME=5
# 기본 전송 크기(바이트)
DEFAULT_TRANSFER_SIZE=4096
# 기본 큐 뎁스
DEFAULT_QDEPTH=32
# 기본 채널 개수
DEFAULT_CHANNELS=1
# 기본 코어 마스크
DEFAULT_CORE_MASK="0x1"

# 테스트할 큐 뎁스 리스트
QUEUE_DEPTH_LIST=(16 32 64 128)
# 테스트할 전송 크기 리스트 (바이트)
TRANSFER_SIZE_LIST=(4096 8192 16384 32768)
# 테스트할 실행 시간 리스트 (초)
RUN_TIME_LIST=(2 5 10)
# 테스트할 채널 개수
CHANNEL_LIST=(1 2 4 8 16)
# 테스트할 코어 마스크
CORE_MASK_LIST=("0x1" "0x3" "0x7" "0xF")

# ==============================
#  뎁스 변화 실험
echo "=== Q-depth 변화 ===" | tee -a $RESULT_FILE
for QDEPTH in "${QUEUE_DEPTH_LIST[@]}"; do
    echo "==============================" | tee -a $RESULT_FILE
    echo "[JoonHee] Test : Q-depth: $QDEPTH" | tee -a $RESULT_FILE
    echo "[JoonHee] Command : sudo ./ioat_perf -q $QDEPTH -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE" | tee -a $RESULT_FILE

    sudo ./ioat_perf -q $QDEPTH -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE >> $RESULT_FILE 2>&1

    echo "[JoonHee] Done !!" | tee -a $RESULT_FILE
done

# ==============================
# 전송 크기 변화 실험
echo "" | tee -a $RESULT_FILE
echo "=== 전송 크기 변화 ===" | tee -a $RESULT_FILE
for SIZE in "${TRANSFER_SIZE_LIST[@]}"; do
    echo "==============================" | tee -a $RESULT_FILE
    echo "[JoonHee] Test : Transfer Size: $SIZE" | tee -a $RESULT_FILE
    echo "[JoonHee] Command : sudo ./ioat_perf -q $DEFAULT_QDEPTH -t $DEFAULT_TIME -o $SIZE" | tee -a $RESULT_FILE

    sudo ./ioat_perf -q $DEFAULT_QDEPTH -t $DEFAULT_TIME -o $SIZE >> $RESULT_FILE 2>&1

    echo "[JoonHee] Done !!" | tee -a $RESULT_FILE
done

# ==============================
# 실행 시간 변화 실험

echo "" | tee -a $RESULT_FILE
echo "=== 실행 시간 변화 ===" | tee -a $RESULT_FILE
for TIME in "${RUN_TIME_LIST[@]}"; do
    echo "==============================" | tee -a $RESULT_FILE
    echo "[JoonHee] Test : Execution Time: $TIME sec" | tee -a $RESULT_FILE
    echo "[JoonHee] Command : sudo ./ioat_perf -q $DEFAULT_QDEPTH -t $TIME -o $DEFAULT_TRANSFER_SIZE" | tee -a $RESULT_FILE

    sudo ./ioat_perf -q $DEFAULT_QDEPTH -t $TIME -o $DEFAULT_TRANSFER_SIZE >> $RESULT_FILE 2>&1

    echo "[JoonHee] Done !!" | tee -a $RESULT_FILE
done

# ==============================
# 한 개의 코어에서 채널 개수 변화 실험
echo "" | tee -a $RESULT_FILE
echo "=== 한 개의 코어에서 채널 개수 변화 실험 ===" | tee -a $RESULT_FILE
for CHANNELS in "${CHANNEL_LIST[@]}"; do
    echo "==============================" | tee -a $RESULT_FILE
    echo "[JoonHee] Test : Channels: $CHANNELS" | tee -a $RESULT_FILE
    echo "[JoonHee] Command : sudo ./ioat_perf -c 0x1 -n $CHANNELS -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE" | tee -a $RESULT_FILE

    sudo ./ioat_perf -c 0x1 -n $CHANNELS -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE >> $RESULT_FILE 2>&1

    echo "[JoonHee] Done !!" | tee -a $RESULT_FILE
done

# ==============================
# 여러 개의 코어에서 실행 실험
echo "" | tee -a $RESULT_FILE
echo "=== 여러 개의 코어에서 실행 실험 ===" | tee -a $RESULT_FILE
for CORES in "${CORE_MASK_LIST[@]}"; do
    echo "==============================" | tee -a $RESULT_FILE
    echo "[JoonHee] Test : Core Mask: $CORES" | tee -a $RESULT_FILE
    echo "[JoonHee] Command : sudo ./ioat_perf -c $CORES -n 1 -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE" | tee -a $RESULT_FILE

    sudo ./ioat_perf -c $CORES -n 1 -t $DEFAULT_TIME -o $DEFAULT_TRANSFER_SIZE >> $RESULT_FILE 2>&1

    echo "[JoonHee] Done !!" | tee -a $RESULT_FILE
done

echo "" | tee -a $RESULT_FILE
echo "=== 모든 실험 완료 ===" | tee -a $RESULT_FILE
echo "실험 종료 시간: $(date)" | tee -a $RESULT_FILE

# 실행 완료 메시지 출력
echo "[JoonHee] Done !!"
