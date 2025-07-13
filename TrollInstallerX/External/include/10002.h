#ifndef lib10002_h
#define lib10002_h

#ifdef __cplusplus
extern "C" {
#endif

// 10002.dylib 函数声明
// 请根据实际的dylib函数进行修改

/**
 * 初始化库
 * @return 0表示成功，非0表示失败
 */
int lib10002_init(void);

/**
 * 执行主要功能
 * @param input 输入数据
 * @param output 输出缓冲区
 * @param output_size 输出缓冲区大小
 * @return 0表示成功，非0表示失败
 */
int lib10002_process(const char* input, char* output, int output_size);

/**
 * 获取版本信息
 * @param version_buffer 版本信息缓冲区
 * @param buffer_size 缓冲区大小
 * @return 0表示成功，非0表示失败
 */
int lib10002_get_version(char* version_buffer, int buffer_size);

/**
 * 清理资源
 */
void lib10002_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif /* lib10002_h */ 