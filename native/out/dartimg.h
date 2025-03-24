#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct ResizeResult {
  uint8_t *data;
  uintptr_t len;
  const uint8_t *message;
} ResizeResult;

int32_t sum(int32_t a, int32_t b);

/**
 * Receives compressed image bytes (e.g. PNG, JPG),
 * resizes it with Lanczos3 (default algorithm), returns raw RGBA buffer.
 */
struct ResizeResult upscale_image_from_bytes(const uint8_t *bytes_ptr,
                                             uintptr_t bytes_len,
                                             uint32_t upscale_factor);

void free_image_buffer(uint8_t *ptr, uintptr_t len);
