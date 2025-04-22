FROM python:3.10-slim

ADD . /heart-python
WORKDIR /heart-python

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "./app.py"]