// examples/accel/perf/accel_perf.c >> v1


/* SPDX-License-Identifier: BSD-3-Clause */
#include "spdk/stdinc.h"
#include "spdk/thread.h"
#include "spdk/env.h"
#include "spdk/event.h"
#include "spdk/log.h"
#include "spdk/string.h"
#include "spdk/accel.h"
#include "spdk/crc32.h"
#include "sys/resource.h"
#include "stdio.h"

static int g_queue_depth = 32;
static int g_time_in_sec = 5;
static bool g_verify = false;
static const char *g_workload_type = NULL;
static struct spdk_app_opts g_opts = {};
static pthread_mutex_t g_workers_lock = PTHREAD_MUTEX_INITIALIZER;
static struct worker_thread *g_workers = NULL;

double get_cpu_usage(void);
long get_memory_bandwidth_usage(void);
void run_auto_qdepth_test(void);

/*  CPU 사용량 측정 */
double get_cpu_usage(void) {
    struct rusage usage;
    getrusage(RUSAGE_SELF, &usage);
    return (usage.ru_utime.tv_sec + usage.ru_stime.tv_sec) +
           (usage.ru_utime.tv_usec + usage.ru_stime.tv_usec) / 1e6;
}

/*  메모리 대역폭 사용량 측정 */
long get_memory_bandwidth_usage(void) {
    FILE *fp = fopen("/proc/meminfo", "r");
    char buffer[256];
    long mem_free = 0;

    while (fgets(buffer, sizeof(buffer), fp)) {
        if (sscanf(buffer, "MemAvailable: %ld kB", &mem_free) == 1) {
            fclose(fp);
            return mem_free;
        }
    }
    fclose(fp);
    return 0;
}

/*  Q-depth 자동 테스트 실행 */
void run_auto_qdepth_test(void) {
    for (int qd = 1; qd <= 64; qd *= 2) {
        printf("Running test with queue depth = %d\n", qd);
        char cmd[256];
        snprintf(cmd, sizeof(cmd), "./accel_perf -d software -w copy -q %d -t 10", qd);

        /*  실행 실패 시 다음 Q-depth로 넘어감 */
        if (system(cmd) != 0) {
            printf("⚠️ Command execution failed: %s\n", cmd);
            continue;
        }

        sleep(1);  //  시스템 리소스 소진 방지
    }
    printf("[joonhee] Auto Q-depth test completed.\n");
}

/*  SPDK 종료 콜백 */
static void shutdown_cb(void) {
    spdk_app_stop(0);
    printf("[joonhee] SPDK application stopped.\n");
}

/*  명령줄 인자 파싱 */
static int parse_args(int ch, char *arg) {
    switch (ch) {
        case 'q': g_queue_depth = atoi(arg); break;
        case 't': g_time_in_sec = atoi(arg); break;
        case 'w': g_workload_type = arg; break;
        case 'y': g_verify = true; break;
        default:
            return -1;
    }
    return 0;
}

/*  사용법 출력 */
static void usage(void) {
    printf("accel_perf options:\n");
    printf("\t[-q queue depth]\n");
    printf("\t[-t time in seconds]\n");
    printf("\t[-w workload type (e.g., copy, fill, crc32c)]\n");
    printf("\t[-y enable verification]\n");
}

/*  SPDK 실행 함수 */
static void accel_perf_run(void *arg1) {
    printf("[joonhee] SPDK Accel Perf Test Running...\n");
    printf("[joonhee] accel_perf_run() completed.\n");
}

/*  main() 함수 */
int main(int argc, char **argv) {
    int g_rc = 0;

    printf("Starting accel_perf...\n");

    pthread_mutex_init(&g_workers_lock, NULL);

    /*  SPDK 애플리케이션 옵션 초기화 */
    spdk_app_opts_init(&g_opts, sizeof(g_opts));
    g_opts.name = "accel_perf";
    g_opts.reactor_mask = "0x1";
    g_opts.shutdown_cb = shutdown_cb;
    g_opts.rpc_addr = NULL;
    g_opts.iova_mode = "va";  //  iova-mode=va 설정

    /*  SPDK 명령줄 인자 파싱 */
    g_rc = spdk_app_parse_args(argc, argv, &g_opts, "q:t:w:y", NULL, parse_args, usage);
    if (g_rc != SPDK_APP_PARSE_ARGS_SUCCESS) {
        return (g_rc == SPDK_APP_PARSE_ARGS_HELP) ? 0 : 1;
    }

    /*  SPDK 애플리케이션 실행 */
    g_rc = spdk_app_start(&g_opts, accel_perf_run, NULL);
    if (g_rc) {
        printf("❌ ERROR: Failed to start SPDK application.\n");
        return 1;  //  실행 실패 시 종료
    }

    /*  CPU 및 메모리 사용량 측정 */
    double cpu_usage = get_cpu_usage();
    long memory_bw = get_memory_bandwidth_usage();
    printf("CPU Usage: %.2f sec\n", cpu_usage);
    printf("Memory Bandwidth Usage: %ld KB\n", memory_bw);
    printf("[joonhee] Performance measurement completed.\n");

    /*  Queue Depth 자동 테스트 실행 */
    run_auto_qdepth_test();

    /*  SPDK 종료 */
    pthread_mutex_destroy(&g_workers_lock);
    spdk_app_fini();
    printf("[joonhee] SPDK application finalized.\n");
    return g_rc;
}
