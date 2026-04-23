use std::ffi::{CString};
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn say_hello() -> *mut c_char {
    CString::new("Hello from Rust!").unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    if s.is_null() { return; }
    unsafe {
        CString::from_raw(s);
    }
}