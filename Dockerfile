FROM directus/directus:latest
USER root
RUN corepack enable # For pnpm
USER node
# Add any necessary extensions here, e.g.:
# RUN pnpm install @directus-labs/collaborative-editing