FROM python

MAINTAINER Dmitry Zelenkovsky <Dmitry.Zelenkovsky@gmail.com>

RUN pip install numpy \
                pillow \
                matplotlib \
                opencv-python \
                python-socketio \
                eventlet \
                flask

WORKDIR /opt/RoboND/code

EXPOSE 4567

CMD [ "python", "drive_rover.py" ]