FROM hugomods/hugo:exts-0.139.0

WORKDIR /src

# Expose default Hugo server port
EXPOSE 1313

# Default command: serve with live reload
CMD ["hugo", "server", "--bind", "0.0.0.0", "--buildDrafts", "--buildFuture"]
