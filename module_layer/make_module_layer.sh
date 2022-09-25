#!/bin/zsh

cd $(pwd)/workspace
docker run --rm \
    --platform linux/x86_64 \
    -v $(pwd):/var/task \
    -v $(pwd)/lib/perl5/site_perl:/opt/lib/perl5/site_perl \
    shogo82148/p5-aws-lambda:build-5.36.al2 \
    cpanm --notest --no-man-pages WebService::Slack::WebApi
zip -9 -r ../out/module-layer.zip .