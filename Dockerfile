# Use uma imagem oficial do Python baseada no Alpine para um tamanho mínimo.
# A tag alpine3.20 é a mais recente disponível para a versão 3.11 do Python.
FROM python:3.11-alpine3.20

# Define variáveis de ambiente para um melhor comportamento do Python no Docker.
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /app

# Copia o arquivo de dependências primeiro para aproveitar o cache do Docker.
COPY requirements.txt .

# Instala dependências de compilação, instala pacotes Python e depois remove
# as dependências de compilação, tudo em uma única camada para otimizar o tamanho.
# Algumas bibliotecas Python precisam ser compiladas, por isso 'build-base' é necessário.
RUN apk add --no-cache --virtual .build-deps build-base && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del .build-deps

# Copia o restante do código da aplicação para o diretório de trabalho.
COPY . .

# Cria um grupo e um usuário não-root (prática de segurança).
# 'addgroup -S' e 'adduser -S' são os comandos para Alpine Linux.
RUN addgroup -S appgroup && adduser -S -G appgroup appuser
RUN chown -R appuser:appgroup /app

# Muda para o usuário não-root.
USER appuser

# Expõe a porta em que a aplicação será executada.
EXPOSE 8000

# Comando para iniciar a aplicação em modo de produção com 4 workers.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload", "--workers", "4"]

