use std::slice;

use super::engine;

#[repr(C)]
pub struct ResizeResult {
    pub success: ResizeSuccess,
    pub error: ResizeError,
    pub is_success: bool,
}

#[repr(C)]
pub struct ResizeSuccess {
    pub data: *mut u8,
    pub len: usize,
}

#[repr(C)]
pub struct ResizeError {
    pub error_code: i32,
    pub message: *const u8,
}

impl ResizeResult {
    /// Creates a new successful resize result with the provided buffer
    fn success(buffer: Vec<u8>) -> Self {
        let len = buffer.len();
        let ptr = buffer.as_ptr() as *mut u8;

        // Prevent deallocation when buffer goes out of scope
        std::mem::forget(buffer);

        Self {
            success: ResizeSuccess { data: ptr, len },
            error: ResizeError {
                error_code: 0,
                message: std::ptr::null(),
            },
            is_success: true,
        }
    }

    /// Creates an error result with null data
    fn error(error_code: ErrorCode, msg: String) -> Self {
        Self {
            success: ResizeSuccess {
                data: std::ptr::null_mut(),
                len: 0,
            },
            error: ResizeError {
                error_code: error_code as i32,
                message: msg.as_ptr() as *const u8,
            },
            is_success: false,
        }
    }
}

enum ErrorCode {
    InvalidInput = 1,
    ResizeFailed = 2,
}

/// Receives compressed image bytes (e.g. PNG, JPG),
/// resizes it with Lanczos3 (default algorithm), returns raw RGBA buffer.
#[no_mangle]
pub extern "C" fn upscale_image_from_bytes(
    bytes_ptr: *const u8,
    bytes_len: usize,
    upscale_factor: f32,
) -> ResizeResult {
    // Validate input parameters
    if bytes_ptr.is_null() || bytes_len == 0 || upscale_factor == 0.0 {
        return ResizeResult::error(ErrorCode::InvalidInput, "Invalid input".to_string());
    }

    // Convert raw pointer to slice safely
    let input = unsafe { slice::from_raw_parts(bytes_ptr, bytes_len) };

    // Check if the input slice is empty
    if input.is_empty() {
        return ResizeResult::error(ErrorCode::InvalidInput, "Empty input".to_string());
    }

    let resize_result = engine::resize_image_inline(input, bytes_len, upscale_factor);

    match resize_result {
        Ok(buffer) => ResizeResult::success(buffer),
        Err(e) => ResizeResult::error(ErrorCode::ResizeFailed, e),
    }
}
