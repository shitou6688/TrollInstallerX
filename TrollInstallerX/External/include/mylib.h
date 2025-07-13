#ifndef mylib_h
#define mylib_h

#ifdef __cplusplus
extern "C" {
#endif

// 示例函数声明
// 请根据您的dylib实际函数进行修改

// 初始化函数
int mylib_init(void);

// 示例功能函数
int mylib_do_something(const char* input, char* output, int output_size);

// 清理函数
void mylib_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif /* mylib_h */ 