FROM mcr.microsoft.com/dotnet/sdk:6.0@sha256:2c83e0a1f2097ed9ade26584f07861b47acb8028db5c41c6cf4cc4d074940dc5 as builder
WORKDIR /src
COPY . /src
RUN cd Wittyer \
    && dotnet publish -f net6.0 -r linux-x64 -c Release -o /output \
    && chmod +x /output/Wittyer

FROM mcr.microsoft.com/dotnet/runtime:6.0@sha256:7c9864325c22e1bc2faae1c6156b002b84cdd1df8307c7a50a3a06812bad5da1
LABEL git_repository=https://git.illumina.com/DASTE/Ilmn.Das.App.Wittyer.git
WORKDIR /opt/Wittyer
RUN apt-get -y update && apt-get -y install tabix libunwind8 openssl procps
COPY --from=builder /output /opt/Wittyer
