#!/bin/bash

# ============================================================================
# Script: create-keystore.sh
# Mô tả: Tạo keystore cho Android signing và chuyển sang Base64
# Cách dùng: ./create-keystore.sh [OPTIONS]
# ============================================================================

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# Giá trị mặc định
# ============================================================================
DEFAULT_KEYSTORE_NAME="rustdesk-keystore.jks"
DEFAULT_ALIAS="rustdesk-key-alias"
DEFAULT_VALIDITY=10000
DEFAULT_KEY_ALG="RSA"
DEFAULT_KEY_SIZE=2048
DEFAULT_DNAME="CN=RustDesk, OU=Development, O=Company, L=Hanoi, ST=Hanoi, C=VN"

# ============================================================================
# Biến toàn cục
# ============================================================================
KEYSTORE_NAME="$DEFAULT_KEYSTORE_NAME"
ALIAS="$DEFAULT_ALIAS"
VALIDITY="$DEFAULT_VALIDITY"
KEY_ALG="$DEFAULT_KEY_ALG"
KEY_SIZE="$DEFAULT_KEY_SIZE"
DNAME="$DEFAULT_DNAME"
STORE_PASS="Xsofts@2024"
KEY_PASS="Xsofts@2024"

# ============================================================================
# Hàm hiển thị help
# ============================================================================
show_help() {
    cat << EOF
Cách dùng: $0 [OPTIONS]

OPTIONS:
    -n, --name NAME          Tên file keystore (mặc định: $DEFAULT_KEYSTORE_NAME)
    -a, --alias ALIAS        Alias của key (mặc định: $DEFAULT_ALIAS)
    -v, --validity DAYS      Thời hạn keystore (ngày) (mặc định: $DEFAULT_VALIDITY)
    -k, --keyalg ALG         Thuật toán key (mặc định: $DEFAULT_KEY_ALG)
    -s, --keysize SIZE       Kích thước key (mặc định: $DEFAULT_KEY_SIZE)
    -d, --dname DNAME        Distinguished name (mặc định: "$DEFAULT_DNAME")
    -sp, --store-pass PASS   Mật khẩu keystore (nếu không có sẽ được hỏi)
    -kp, --key-pass PASS     Mật khẩu key (nếu không có sẽ dùng store-pass)
    -h, --help               Hiển thị trợ giúp này

Ví dụ:
    $0                                                    # Dùng giá trị mặc định
    $0 -n my-keystore.jks -a my-alias                     # Tên và alias tùy chỉnh
    $0 -sp mypassword -kp mypassword                      # Mật khẩu tùy chỉnh
EOF
}

# ============================================================================
# Hàm in thông báo
# ============================================================================
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ️ $1${NC}"; }

# ============================================================================
# Hàm chuyển file sang Base64 - Cách 1: dùng openssl
# ============================================================================
convert_base64_openssl() {
    local file="$1"
    if command -v openssl >/dev/null 2>&1; then
        openssl base64 -in "$file" | tr -d '\n'
        return 0
    fi
    return 1
}

# ============================================================================
# Hàm chuyển file sang Base64 - Cách 2: dùng xxd (có sẵn trên macOS)
# ============================================================================
convert_base64_xxd() {
    local file="$1"
    if command -v xxd >/dev/null 2>&1; then
        xxd -p -c 1000000 "$file" | tr -d '\n' | xxd -r -p | base64 2>/dev/null | tr -d '\n'
        return 0
    fi
    return 1
}

# ============================================================================
# Hàm chuyển file sang Base64 - Cách 3: dùng perl
# ============================================================================
convert_base64_perl() {
    local file="$1"
    if command -v perl >/dev/null 2>&1; then
        perl -MMIME::Base64 -e 'open F, shift; print encode_base64(join("", <F>));' "$file" | tr -d '\n'
        return 0
    fi
    return 1
}

# ============================================================================
# Hàm chuyển file sang Base64 - Cách 4: dùng python
# ============================================================================
convert_base64_python() {
    local file="$1"
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import base64; print(base64.b64encode(open('$file', 'rb').read()).decode(), end='')"
        return 0
    fi
    if command -v python >/dev/null 2>&1; then
        python -c "import base64; print(base64.b64encode(open('$file', 'rb').read()).decode(), end='')"
        return 0
    fi
    return 1
}

# ============================================================================
# Hàm chuyển file sang Base64 - Cách 5: dùng cat + base64 (cách cũ)
# ============================================================================
convert_base64_cat() {
    local file="$1"
    cat "$file" | base64 | tr -d '\n'
    return 0
}

# ============================================================================
# Chuyển file keystore sang Base64 (thử nhiều cách)
# ============================================================================
convert_to_base64() {
    local keystore_file="$1"
    local output_var_name="$2"
    local base64_content=""
    
    # Kiểm tra file tồn tại
    if [[ ! -f "$keystore_file" ]]; then
        print_error "Không tìm thấy file: $keystore_file"
        return 1
    fi
    
    # Kiểm tra file không rỗng
    if [[ ! -s "$keystore_file" ]]; then
        print_error "File trống: $keystore_file"
        return 1
    fi
    
    # Lấy kích thước file
    local file_size=$(stat -f%z "$keystore_file" 2>/dev/null || stat -c%s "$keystore_file" 2>/dev/null)
    print_info "Kích thước file keystore: $file_size bytes"
    
    # Thử các phương pháp khác nhau
    echo ""
    print_info "Thử phương pháp 1: openssl..."
    base64_content=$(convert_base64_openssl "$keystore_file")
    if [[ -n "$base64_content" && ${#base64_content} -gt 100 ]]; then
        print_success "Thành công với openssl (${#base64_content} chars)"
    else
        print_info "Phương pháp 1 thất bại, thử phương pháp 2..."
        base64_content=$(convert_base64_cat "$keystore_file")
        if [[ -n "$base64_content" && ${#base64_content} -gt 100 ]]; then
            print_success "Thành công với cat+base64 (${#base64_content} chars)"
        else
            print_info "Phương pháp 2 thất bại, thử phương pháp 3..."
            base64_content=$(convert_base64_xxd "$keystore_file")
            if [[ -n "$base64_content" && ${#base64_content} -gt 100 ]]; then
                print_success "Thành công với xxd (${#base64_content} chars)"
            else
                print_info "Phương pháp 3 thất bại, thử phương pháp 4..."
                base64_content=$(convert_base64_perl "$keystore_file")
                if [[ -n "$base64_content" && ${#base64_content} -gt 100 ]]; then
                    print_success "Thành công với perl (${#base64_content} chars)"
                else
                    print_info "Phương pháp 4 thất bại, thử phương pháp 5..."
                    base64_content=$(convert_base64_python "$keystore_file")
                    if [[ -n "$base64_content" && ${#base64_content} -gt 100 ]]; then
                        print_success "Thành công với python (${#base64_content} chars)"
                    else
                        print_error "Tất cả phương pháp đều thất bại"
                        return 1
                    fi
                fi
            fi
        fi
    fi
    
    # Gán vào biến output
    eval "$output_var_name=\"\$base64_content\""
    return 0
}

# ============================================================================
# Hàm copy vào clipboard
# ============================================================================
copy_to_clipboard() {
    local content="$1"
    local content_len=${#content}
    
    if [[ -z "$content" ]]; then
        print_error "Không có nội dung để copy"
        return 1
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "$content" | pbcopy
        print_success "Đã copy $content_len chars vào clipboard (macOS)"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v xclip >/dev/null 2>&1; then
            echo "$content" | xclip -selection clipboard
            print_success "Đã copy $content_len chars vào clipboard (Linux/xclip)"
        else
            print_info "Không có xclip, Base64 sẽ được in ra màn hình"
        fi
    fi
}

# ============================================================================
# Parse tham số dòng lệnh
# ============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name) KEYSTORE_NAME="$2"; shift 2 ;;
        -a|--alias) ALIAS="$2"; shift 2 ;;
        -v|--validity) VALIDITY="$2"; shift 2 ;;
        -k|--keyalg) KEY_ALG="$2"; shift 2 ;;
        -s|--keysize) KEY_SIZE="$2"; shift 2 ;;
        -d|--dname) DNAME="$2"; shift 2 ;;
        -sp|--store-pass) STORE_PASS="$2"; shift 2 ;;
        -kp|--key-pass) KEY_PASS="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        *) print_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

# ============================================================================
# Hỏi mật khẩu
# ============================================================================
if [[ -z "$STORE_PASS" ]]; then
    echo -n "🔐 Nhập keystore password (tối thiểu 6 ký tự): "
    read -s STORE_PASS
    echo ""
fi

if [[ -z "$KEY_PASS" ]]; then
    KEY_PASS="$STORE_PASS"
    print_info "Sử dụng chung mật khẩu với keystore"
fi

# ============================================================================
# Tạo keystore (nếu chưa có hoặc ghi đè)
# ============================================================================
if [[ -f "$KEYSTORE_NAME" ]]; then
    print_info "File $KEYSTORE_NAME đã tồn tại"
    echo -n "⚠️ Bạn có muốn ghi đè không? (y/N): "
    read -r OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        print_info "Thoát, không ghi đè file"
        exit 0
    fi
fi

print_info "Đang tạo keystore: $KEYSTORE_NAME"

keytool -genkey -v \
    -keystore "$KEYSTORE_NAME" \
    -alias "$ALIAS" \
    -keyalg "$KEY_ALG" \
    -keysize "$KEY_SIZE" \
    -validity "$VALIDITY" \
    -dname "$DNAME" \
    -storepass "$STORE_PASS" \
    -keypass "$KEY_PASS" 2>&1

if [[ $? -ne 0 ]]; then
    print_error "Tạo keystore thất bại"
    exit 1
fi

print_success "Đã tạo keystore thành công: $KEYSTORE_NAME"

# ============================================================================
# Chuyển sang Base64
# ============================================================================
echo ""
print_info "Đang chuyển keystore sang Base64..."

BASE64_CONTENT=""
if ! convert_to_base64 "$KEYSTORE_NAME" "BASE64_CONTENT"; then
    print_error "Chuyển đổi Base64 thất bại"
    exit 1
fi

# Hiển thị 100 ký tự đầu
print_info "Base64 (100 ký tự đầu): ${BASE64_CONTENT:0:100}..."

# ============================================================================
# Lưu Base64 ra file
# ============================================================================
BASE64_FILE="${KEYSTORE_NAME%.jks}-base64.txt"
echo "$BASE64_CONTENT" > "$BASE64_FILE"

if [[ -f "$BASE64_FILE" ]] && [[ -s "$BASE64_FILE" ]]; then
    FILE_SIZE=$(stat -f%z "$BASE64_FILE" 2>/dev/null || stat -c%s "$BASE64_FILE" 2>/dev/null)
    print_success "Đã lưu Base64 vào file: $BASE64_FILE (${FILE_SIZE} bytes)"
else
    print_error "Không thể lưu file Base64"
    exit 1
fi

# ============================================================================
# Copy vào clipboard
# ============================================================================
echo ""
copy_to_clipboard "$BASE64_CONTENT"

# ============================================================================
# In hướng dẫn
# ============================================================================
echo ""
echo "============================================================================"
echo "📋 HƯỚNG DẪN CẤU HÌNH GITHUB SECRETS"
echo "============================================================================"
echo ""
echo "1️⃣ Mở file Base64: cat $BASE64_FILE"
echo "   Hoặc dùng lệnh: cat $BASE64_FILE | pbcopy"
echo ""
echo "2️⃣ Vào GitHub repository -> Settings -> Secrets and variables -> Actions"
echo ""
echo "3️⃣ Thêm các secret sau:"
echo ""
echo "   ┌─────────────────────────────┬────────────────────────────────────────┐"
echo "   │ Secret Name                 │ Value                                  │"
echo "   ├─────────────────────────────┼────────────────────────────────────────┤"
echo "   │ KEYSTORE_BASE64             │ (nội dung trong file $BASE64_FILE) │"
echo "   │ KEYSTORE_PASSWORD           │ $STORE_PASS                            │"
echo "   │ KEY_ALIAS                   │ $ALIAS                                 │"
echo "   │ KEY_PASSWORD                │ $KEY_PASS                              │"
echo "   └─────────────────────────────┴────────────────────────────────────────┘"
echo ""
echo "============================================================================"
print_success "Hoàn tất!"