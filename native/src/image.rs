use fast_image_resize::{self as fir};
use fir::{images::Image, images::TypedImageRef, IntoImageView, PixelType, Resizer};
use image::{DynamicImage, GenericImageView};
use std::slice;

#[repr(C)]
pub struct ResizeResult {
    pub data: *mut u8,
    pub len: usize,
    pub message: *const u8,
}

impl ResizeResult {
    /// Creates a new successful resize result with the provided buffer
    fn new(buffer: Vec<u8>, message: *const u8) -> Self {
        let len = buffer.len();
        let ptr = buffer.as_ptr() as *mut u8;
        
        // Prevent deallocation when buffer goes out of scope
        std::mem::forget(buffer);
        
        Self { 
            data: ptr, 
            len,
            message,
        }
    }
    
    /// Creates an error result with null data
    fn error(me: *const u8) -> Self {
        Self {
            data: std::ptr::null_mut(),
            len: 0,
            message: me,
        }
    }
}

/// Receives compressed image bytes (e.g. PNG, JPG),
/// resizes it with Lanczos3 (default algorithm), returns raw RGBA buffer.
#[no_mangle]
pub extern "C" fn upscale_image_from_bytes(
    bytes_ptr: *const u8,
    bytes_len: usize,
    upscale_factor: u32,
) -> ResizeResult {
    // Validate input parameters
    if bytes_ptr.is_null() || bytes_len == 0 || upscale_factor == 0 {
        return ResizeResult::error(
            "Invalid input parameters".as_ptr() as *const u8,
        );
    }
    
    // Convert raw pointer to slice safely
    let input = unsafe { slice::from_raw_parts(bytes_ptr, bytes_len) };

    // Perform the resize operation
    match resize_image_from_bytes(input, upscale_factor) {
        Ok(buffer) => ResizeResult::new(buffer, std::ptr::null()),
        Err(_) => ResizeResult::error(
            "Resize operation failed".as_ptr() as *const u8,
        ),
    }
}

/// Internal function to handle the actual image resizing logic
fn resize_image_from_bytes(input: &[u8], upscale_factor: u32) -> Result<Vec<u8>, String> {
    // Decode image (any format) into a DynamicImage
    let dyn_img = image::load_from_memory(input)
        .map_err(|e| format!("Failed to decode image: {}", e))?;

    // Calculate new dimensions
    let (src_width, src_height) = dyn_img.dimensions();
    let (dst_width, dst_height) = (
        (src_width as f32 * upscale_factor as f32).round() as u32,
        (src_height as f32 * upscale_factor as f32).round() as u32,
    );

    println!("Resizing from {}x{} to {}x{}", src_width, src_height, dst_width, dst_height);
    
    // Ensure dimensions are valid
    if dst_width == 0 || dst_height == 0 || dst_width > 16384 || dst_height > 16384 {
        return Err("Invalid target dimensions".to_string());
    }

    // Create a new image with the desired dimensions
    let mut dst_image = Image::new(dst_width, dst_height, PixelType::U8x4);
    let my_dyn_img = MyDynamicImage { image: dyn_img };

    // Create a resizer instance
    let mut resizer = Resizer::new();
    
    // Perform the resize operation
    resizer.resize(&my_dyn_img, &mut dst_image, None)
        .map_err(|e| format!("Resize error: {:?}", e))?;

    // Get the buffer from the resized image
    Ok(dst_image.buffer().to_vec())
}

#[no_mangle]
pub extern "C" fn free_image_buffer(ptr: *mut u8, len: usize) {
    if !ptr.is_null() && len > 0 {
        unsafe {
            drop(Vec::from_raw_parts(ptr, len, len));
        }
    }
}

pub struct MyDynamicImage {
    pub image: DynamicImage,
}

impl IntoImageView for MyDynamicImage {
    fn pixel_type(&self) -> Option<PixelType> {
        match self.image {
            DynamicImage::ImageLuma8(_) => Some(PixelType::U8),
            DynamicImage::ImageLumaA8(_) => Some(PixelType::U8x2),
            DynamicImage::ImageRgb8(_) => Some(PixelType::U8x3),
            DynamicImage::ImageRgba8(_) => Some(PixelType::U8x4),
            DynamicImage::ImageLuma16(_) => Some(PixelType::U16),
            DynamicImage::ImageLumaA16(_) => Some(PixelType::U16x2),
            DynamicImage::ImageRgb16(_) => Some(PixelType::U16x3),
            DynamicImage::ImageRgba16(_) => Some(PixelType::U16x4),
            _ => None,
        }
    }

    fn width(&self) -> u32 {
        self.image.width()
    }

    fn height(&self) -> u32 {
        self.image.height()
    }

    fn image_view<P: fir::PixelTrait>(&self) -> Option<impl fir::ImageView<Pixel = P>> {
        if let Ok(pixel_type) = self
            .pixel_type()
            .ok_or(fir::ImageError::UnsupportedPixelType)
        {
            if P::pixel_type() == pixel_type {
                return TypedImageRef::<P>::from_buffer(
                    self.width(),
                    self.height(),
                    self.image.as_bytes(),
                )
                .ok();
            }
        }
        None
    }
}