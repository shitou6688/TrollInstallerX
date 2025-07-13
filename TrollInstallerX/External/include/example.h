#ifndef example_h
#define example_h

#ifdef __cplusplus
extern "C" {
#endif

// 示例dylib函数声明
// 请根据您的实际dylib函数进行修改

/**
 * 初始化库
 * @return 0表示成功，非0表示失败
 */
int example_init(void);

/**
 * 执行主要功能
 * @param input 输入字符串
 * @param output 输出缓冲区
 * @param output_size 输出缓冲区大小
 * @return 0表示成功，非0表示失败
 */
int example_process(const char* input, char* output, int output_size);

/**
 * 获取版本信息
 * @param version_buffer 版本信息缓冲区
 * @param buffer_size 缓冲区大小
 * @return 0表示成功，非0表示失败
 */
int example_get_version(char* version_buffer, int buffer_size);

/**
 * 清理资源
 */
void example_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif /* example_h */ 