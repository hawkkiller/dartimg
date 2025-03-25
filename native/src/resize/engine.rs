use std::io::Cursor;

use image::{DynamicImage, GenericImageView};

pub fn resize_image_inline(
    bytes: &[u8],
    length: usize,
    upscale_factor: f32,
) -> Result<Vec<u8>, String> {
    if bytes.is_empty() || length == 0 {
        return Err("Invalid input: empty bytes or length".to_string());
    }

    log::debug!("Resizing image with length: {}", length);

    let image = image::load_from_memory(bytes).map_err(|e| e.to_string())?;
    let image_format = image::guess_format(bytes).map_err(|e| e.to_string())?;

    log::debug!("Guessed Image format: {:?}", image_format);
    let resized_image = resize_dynamic_image(&image, upscale_factor)?;

    let mut buffer = Vec::new();
    resized_image
        .write_to(&mut Cursor::new(&mut buffer), image_format)
        .map_err(|e| e.to_string())?;

    Ok(buffer)
}

/// Upscales an image by a given factor.
pub fn resize_dynamic_image(
    image: &DynamicImage,
    upscale_factor: f32,
) -> Result<DynamicImage, String> {
    let (width, height) = image.dimensions();

    let new_width = (width as f32 * upscale_factor).round() as u32;
    let new_height = (height as f32 * upscale_factor).round() as u32;

    log::debug!(
        "Resizing image from {}x{} to {}x{}",
        width,
        height,
        new_width,
        new_height
    );

    if new_width == 0 || new_height == 0 {
        log::error!("Invalid dimensions after resizing: {}x{}", new_width, new_height);
        return Err("Invalid dimensions after resizing".to_string());
    }

    let resized_image = image.resize(new_width, new_height, image::imageops::FilterType::Lanczos3);
    Ok(resized_image)
}
