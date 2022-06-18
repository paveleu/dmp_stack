FROM alpine:3.14


RUN mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh \
    && passwd -u root \
    && echo "$ssh_pub_key" > /root/.ssh/authorized_keys \
    && apk add thttpd openrc openssh \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel

RUN mkdir /public

RUN yes y | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa &&\
    mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys &&\
    cp ~/.ssh/id_rsa /public/ssh_key && chmod 666 /public/ssh_key

EXPOSE 80
EXPOSE 22

WORKDIR /public

ENTRYPOINT ["sh", "-c", "rc-status; rc-service sshd start; thttpd -D -h 0.0.0.0 -p 80 -d /public -u root -l - -M 60"]
