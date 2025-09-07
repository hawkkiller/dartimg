#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct ResizeSuccess {
  uint8_t *data;
  uintptr_t len;
} ResizeSuccess;

typedef struct ResizeError {
  int32_t error_code;
  const char *message;
} ResizeError;

typedef struct ResizeResult {
  struct ResizeSuccess success;
  struct ResizeError error;
  bool is_success;
} ResizeResult;

int32_t sum(int32_t a, int32_t b);

struct ResizeResult *upscale_image_from_bytes(const uint8_t *bytes_ptr,
                                              uintptr_t bytes_len,
                                              float upscale_factor,
                                              const uint8_t *input_image_format,
                                              const uint8_t *output_image_format);

void deallocate_buffer(uint8_t *ptr, uintptr_t len);

void deallocate_resize_result(struct ResizeResult *ptr);
