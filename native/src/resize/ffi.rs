use std::{slice, ffi::CString};
use std::os::raw::c_char;

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
    pub message: *const c_char,
}

impl ResizeResult {
    /// Allocates and returns a successful resize result with the provided buffer
    fn success(buffer: Vec<u8>) -> *mut Self {
        let len = buffer.len();
        let ptr = buffer.as_ptr() as *mut u8;

        // Prevent Rust from dropping the buffer
        std::mem::forget(buffer);

        let result = ResizeResult {
            success: ResizeSuccess { data: ptr, len },
            error: ResizeError {
                error_code: 0,
                message: std::ptr::null(),
            },
            is_success: true,
        };

        Box::into_raw(Box::new(result))
    }

    /// Allocates and returns an error result with a heap-allocated error message
    fn error(error_code: ErrorCode, msg: String) -> *mut Self {
        let c_string = CString::new(msg).unwrap();
        let message_ptr = c_string.as_ptr();

        // Prevent Rust from freeing the CString
        std::mem::forget(c_string);

        let result = ResizeResult {
            success: ResizeSuccess {
                data: std::ptr::null_mut(),
                len: 0,
            },
            error: ResizeError {
                error_code: error_code as i32,
                message: message_ptr,
            },
            is_success: false,
        };

        Box::into_raw(Box::new(result))
    }
}

#[repr(C)]
enum ErrorCode {
    InvalidInput = 1,
    ResizeFailed = 2,
}

#[no_mangle]
pub extern "C" fn upscale_image_from_bytes(
    bytes_ptr: *const u8,
    bytes_len: usize,
    upscale_factor: f32,
) -> *mut ResizeResult {
    if bytes_ptr.is_null() || bytes_len == 0 || upscale_factor == 0.0 {
        return ResizeResult::error(ErrorCode::InvalidInput, "Invalid input".to_string());
    }

    let input = unsafe { slice::from_raw_parts(bytes_ptr, bytes_len) };

    if input.is_empty() {
        return ResizeResult::error(ErrorCode::InvalidInput, "Empty input".to_string());
    }

    match engine::resize_image_inline(input, bytes_len, upscale_factor) {
        Ok(buffer) => ResizeResult::success(buffer),
        Err(e) => ResizeResult::error(ErrorCode::ResizeFailed, e),
    }
}

#[no_mangle]
pub extern "C" fn deallocate_buffer(ptr: *mut u8, len: usize) {
    if !ptr.is_null() && len > 0 {
        unsafe {
            drop(Vec::from_raw_parts(ptr, len, len));
        }
    }
}

#[no_mangle]
pub extern "C" fn deallocate_resize_result(ptr: *mut ResizeResult) {
    println!("Deallocating ResizeResult");
    if ptr.is_null() {
        return;
    }

    unsafe {
        let result = Box::from_raw(ptr);

        if result.is_success && !result.success.data.is_null() && result.success.len > 0 {
            let vec = Vec::from_raw_parts(result.success.data, result.success.len, result.success.len);
            println!("Deallocating buffer of length {}", vec.len());
            drop(vec);
        }

        if !result.error.message.is_null() {
            // SAFETY: We assume this was originally allocated via CString
            let _ = CString::from_raw(result.error.message as *mut i8);
        }

        // result (Box) is dropped automatically here
        println!("ResizeResult deallocated");
    }
}
