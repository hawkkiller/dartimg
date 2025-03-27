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
  const uint8_t *message;
} ResizeError;

typedef struct ResizeResult {
  struct ResizeSuccess success;
  struct ResizeError error;
  bool is_success;
} ResizeResult;

int32_t sum(int32_t a, int32_t b);

/**
 * Receives compressed image bytes (e.g. PNG, JPG),
 * resizes it with Lanczos3 (default algorithm), returns raw RGBA buffer.
 */
struct ResizeResult upscale_image_from_bytes(const uint8_t *bytes_ptr,
                                             uintptr_t bytes_len,
                                             float upscale_factor);

void deallocate_buffer(uint8_t *ptr, uintptr_t len);
