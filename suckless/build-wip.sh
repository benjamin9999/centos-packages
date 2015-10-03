fpm -s dir -t rpm \
    -n "rqdq-suckless" \
    -C dest \
    -d "libX11 >= 1.6.0" \
    -d "libXinerama >= 1.1.3" \
    -d "libxcb >= 1.9.1" \
    -d "libXext >= 1.3.2" \
    -d "libXau >= 1.0.6" \
    -v "1.0.0" \
    --iteration 1 \
    --rpm-user root --rpm-group root
    usr
