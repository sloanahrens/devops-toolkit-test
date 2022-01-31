FROM devopsfaith/krakend:1.1.1

COPY ./krakend.json /etc/krakend/krakend.json

EXPOSE 9999

CMD ["run", "-d", "-c", "/etc/krakend/krakend.json"]