FROM python:3.10-slim

ADD . /diabetes-python
WORKDIR /diabetes-python

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "./app.py"]

