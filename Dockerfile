FROM jaspajjr/data-science-dockerfile

COPY container-entrypoint.sh /entry
RUN chmod 0755 /entry

RUN useradd -ms /bin/bash defaultUser && adduser defaultUser sudo

COPY requirements.txt /data/requirements.txt
RUN pip install -r /data/requirements.txt

RUN mkdir /results

COPY training /data


USER defaultUser
CMD ["start"]
ENTRYPOINT [ "/entry" ]
