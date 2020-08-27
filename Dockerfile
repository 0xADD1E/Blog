FROM rust:slim AS zola-build
WORKDIR /src
RUN git clone https://github.com/getzola/zola.git zola
WORKDIR /src/zola
RUN cargo build --release

FROM scratch AS web-build
WORKDIR /src
COPY --from=zola-build /src/zola/target/release/zola /
COPY . /src
RUN /zola build

FROM nginx
COPY --from=web-build /src/public/* /usr/share/nginx/html/
