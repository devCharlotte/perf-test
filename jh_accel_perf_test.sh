ssl@cse1:~/jh_spdk/accelTest/spdk/build/examples$ cat jh_accel_perf_test.sh

#!/bin/bash

# 로그 파일 초기화
LOG_FILE="accel_perf_results.log"
echo "SPDK accel_perf performance test by JoonHee" > $LOG_FILE
echo "==============================" >> $LOG_FILE
echo "실행 시간: $(date)" >> $LOG_FILE
echo "" >> $LOG_FILE

# accel_perf 실행 함수
run_test() {
    CMD=$1
    DESC=$2  # 설명 추가
    echo -e "[JoonHee] Running : $DESC"
    echo "[JoonHee] Command : $CMD"

    echo "" >> $LOG_FILE
    echo "==============================" >> $LOG_FILE
    echo "[JoonHee] Test : $DESC" >> $LOG_FILE
    echo "[JoonHee] Command : $CMD" >> $LOG_FILE
    echo "------------------------------" >> $LOG_FILE

    START_TIME=$(date +%s)
    eval $CMD >> $LOG_FILE 2>&1
    EXIT_CODE=$?
    END_TIME=$(date +%s)

    if [ $EXIT_CODE -ne 0 ]; then
        echo "[ERROR] 실행 실패: $CMD" | tee -a $LOG_FILE
    fi

    echo "실행 시간: $(($END_TIME - $START_TIME)) 초" >> $LOG_FILE
    echo "" >> $LOG_FILE
}

# 큐 뎁스 변화 테스트
echo "=== Q-depth 변화 ===" >> $LOG_FILE
for Q in 16 32 64 128; do
    run_test "sudo ./accel_perf -q $Q -T 1 -o 4096 -t 5 -w copy -M software" "Q-depth: $Q"
done

# 스레드 개수 변화 테스트
echo "=== 스레드 개수 변화 ===" >> $LOG_FILE
for T in 1 2 4 8; do
    run_test "sudo ./accel_perf -q 32 -T $T -o 4096 -t 5 -w copy -M software" "Thread Count: $T"
done

# 전송 크기 변화 테스트
echo "=== 전송 크기 변화 ===" >> $LOG_FILE
for O in 4096 8192 16384 32768; do
    run_test "sudo ./accel_perf -q 32 -T 1 -o $O -t 5 -w copy -M software" "Transfer Size: $O"
done

# 실행 시간 변화 테스트
echo "=== 실행 시간 변화 ===" >> $LOG_FILE
for T in 2 5 10; do
    run_test "sudo ./accel_perf -q 32 -T 1 -o 4096 -t $T -w copy -M software" "Execution Time: $T sec"
done

echo "[JoonHee] Done !!"
