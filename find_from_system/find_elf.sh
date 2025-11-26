#!/usr/bin/env bash
# find_big_elf.sh - 查找系统中大于 10MiB 的 ELF 文件

echo "正在搜索大于 10MiB 的 ELF 文件（这可能需要几分钟）..."
echo "=================================================="

find / 2>/dev/null \
  -type f \
  -size +10M \
  ! -path "/proc/*" \
  ! -path "/sys/*" \
  ! -path "/dev/*" \
  ! -path "/run/*" \
  ! -path "/tmp/*" \
  ! -path "*/.cache/*" \
  ! -path "*/snap/*" \
  -exec sh -c '
    case $(file -bi "$1" 2>/dev/null) in
      *application/x-executable*|*application/x-sharedlib*|*application/x-pie-executable*)
        printf "%10s  %s\n" "$(du -h "$1" | cut -f1)" "$1"
        ;;
    esac
  ' _ {} \; | sort -hr | nl

echo "=================================================="
echo "搜索完成"
~               