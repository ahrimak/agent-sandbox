FROM fedora:45

LABEL org.opencontainers.image.source=https://github.com/ahrimak/agent-sandbox

RUN dnf -y update \
	&& dnf -y install \
		curl \
		git \
		bubblewrap \
		vim \
	&& dnf clean all

ARG USERNAME=agent
ARG UID=1000
ARG GID=1000

RUN groupadd --gid $GID $USERNAME \
	&& useradd --uid $UID --gid $GID -m -s /bin/bash $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -fsSL https://herdr.dev/install.sh | sh

CMD ["sleep", "infinity"]
