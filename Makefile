-include .env

# Architecture detection for cross-platform builds
# This ensures containers built on macOS/ARM64 will work in GCP Cloud Run (linux/amd64)
ARCH := $(shell uname -m)
PLATFORM_FLAG := $(if $(filter arm64,$(ARCH)),--platform=linux/amd64,)

usage:
	@echo "\nUsage : \033[0;35mmake <commands>\033[0m\n"
	@echo "The following commands are available:"
	@echo "\n\033[0;34m--- Setup ---\033[0m"
	@echo "\033[0;35msetup\033[0m\t\t\tConfigures the \033[0;37mgcloud\033[0m SDK before running other commands"
	@echo "\033[0;35msetup.cloud\033[0m\t\tInitializes the Google Cloud Project for the first time"
	@echo "\033[0;35msetup.bucket\033[0m\t\tInitializes the Google Cloud Storage bucket for the first time"
	@echo "\033[0;35msetup.firestore\033[0m\t\tInitializes the Google Cloud Firestore database for the first time"
	@echo "\033[0;35msetup.iam\033[0m\t\tCreates the Google Cloud IAM service account associated with the Cloud Run servers"
	@echo "\033[0;35msetup.buildx\033[0m\t\tCreates and configures Docker buildx builder for cross-platform builds"
	@echo "\033[0;35msetup.qemu\033[0m\t\tInstalls QEMU emulation layers for cross-platform builds"
	@echo "\033[0;35msetup.crossplatform\033[0m\tSets up both QEMU and buildx for cross-platform builds"
	@echo "\n\033[0;34m--- Build ---\033[0m"
	@echo "\033[0;35mbuild.lighthouse\033[0m\tBuilds the Lighthouse Server Cloud Run Docker image"
	@echo "\033[0;35mbuild.phpcs\033[0m\t\tBuilds the PHPCS Server Cloud Run Docker image"
	@echo "\033[0;35mbuild.sync\033[0m\t\tBuilds the Sync Server Cloud Run Docker image"
	@echo "\n\033[0;34m--- Push ---\033[0m"
	@echo "\033[0;35mpush.lighthouse\033[0m\t\tPushes the Lighthouse Server Cloud Run Docker image to Container Registry"
	@echo "\033[0;35mpush.phpcs\033[0m\t\tPushes the PHPCS Server Cloud Run Docker image to Container Registry"
	@echo "\033[0;35mpush.sync\033[0m\t\tPushes the Sync Server Cloud Run Docker image to Container Registry"
	@echo "\n\033[0;34m--- Start ---\033[0m"
	@echo "\033[0;35mstart.lighthouse\033[0m\tStarts the Lighthouse Server Cloud Run Docker image locally"
	@echo "\033[0;35mstart.phpcs\033[0m\t\tStarts the PHPCS Server Cloud Run Docker image locally"
	@echo "\033[0;35mstart.sync\033[0m\t\tStarts the Sync Server Cloud Run Docker image locally"
	@echo "\n\033[0;34m--- Deploy ---\033[0m"
	@echo "\033[0;35mdeploy.api\033[0m\t\tDeploys the API Server to Google Cloud Functions"
	@echo "\033[0;35mdeploy.spec\033[0m\t\tDeploys the OpenAPI Specification Server to Google Cloud Functions"
	@echo "\033[0;35mdeploy.firebase\033[0m\t\tDeploys the VuePress documentation site to Firebase hosting"
	@echo "\033[0;35mdeploy.firebase\033[0m\t\tDeploys the Firestore configuration files (rules, indexes) to Firebase"
	@echo "\033[0;35mdeploy.firebase\033[0m\t\tDeploys the Firestore configuration files (rules, indexes) to Firebase"
	@echo "\033[0;35mdeploy.lighthouse\033[0m\tDeploys the Lighthouse Server to Google Cloud Run"
	@echo "\033[0;35mdeploy.phpcs\033[0m\t\tDeploys the PHPCS Server to Google Cloud Run"
	@echo "\033[0;35mdeploy.sync\033[0m\t\tDeploys the Sync Server to Google Cloud Run"
	@echo "\033[0;35mdeploy.iam\033[0m\t\tBinds the Google Cloud IAM service account to the Cloud Run servers"
	@echo "\033[0;35mdeploy.topics\033[0m\t\tDeploys the topics to Google Cloud Pub/Sub"
	@echo "\033[0;35mdeploy.pubsub\033[0m\t\tSubscribes to the topics in Google Cloud Pub/Sub"
	@echo "\033[0;35mdeploy.scheduler\033[0m\tDeploys the cron schedule used by the Sync Server to Google Cloud Scheduler"
	@echo "\n\033[0;34m--- Describe ---\033[0m"
	@echo "\033[0;35mdescribe.lighthouse\033[0m\tObtains the Google Cloud Run endpoint URL for the Lighthouse Server"
	@echo "\033[0;35mdescribe.phpcs\033[0m\t\tObtains the Google Cloud Run endpoint URL for the PHPCS Server"
	@echo "\033[0;35mdescribe.sync\033[0m\t\tObtains the Google Cloud Run endpoint URL for the Sync Server"
	@echo "\n\033[0;34m--- Delete ---\033[0m"
	@echo "\033[0;35mdelete.files\033[0m\t\tDeletes all files and directories recursively and multi-threaded in the Cloud Storage bucket"
	@echo "\033[0;35mdelete.firestore\033[0m\tDeletes all data from the Firestore database"
	@echo "\033[0;35mdelete.scheduler\033[0m\tDeletes the cron schedule for the Sync Server from Google Cloud Scheduler"
	@echo "\n\033[0;34m--- Destroy ---\033[0m"
	@echo "\033[0;35mdestroy\033[0m\t\t\t\033[0;31mWARNING: Destroys all GCP resources created by this project\033[0m"
	@echo "\033[0;35mdestroy.cloudrun\033[0m\t\tDestroys all Cloud Run services (lighthouse-server, phpcs-server, sync-server)"
	@echo "\033[0;35mdestroy.functions\033[0m\tDestroys all Cloud Functions (api, spec)"
	@echo "\033[0;35mdestroy.pubsub\033[0m\t\tDestroys all Pub/Sub subscriptions"
	@echo "\033[0;35mdestroy.topics\033[0m\t\tDestroys all Pub/Sub topics"
	@echo "\033[0;35mdestroy.iam\033[0m\t\tDestroys IAM service accounts and bindings"
	@echo "\033[0;35mdestroy.firebase\033[0m\tDestroys Firebase hosting configuration"
	@echo "\033[0;35mdestroy.bucket\033[0m\t\tDestroys the Cloud Storage bucket"
	@echo "\033[0;35mdestroy.scheduler\033[0m\tDestroys the Cloud Scheduler job"
	@echo "\033[0;35mdestroy.appengine\033[0m\tAttempts to disable App Engine (if possible)"
	@echo "\n\033[0;34m--- Download ---\033[0m"
	@echo "\033[0;35mdownload.keys\033[0m\t\tDownloads a very permissive \033[0;37mservice-account.json\033[0m for local development (do not use with GitHub Actions)"
	@echo "\n"

setup:
	@gcloud config set project ${GOOGLE_CLOUD_PROJECT}
	@gcloud config set gcloudignore/enabled true
	@gcloud config set functions/region us-central1
	@gcloud config set run/region us-central1
	@gcloud config set run/platform managed

setup.cloud: setup
	@gcloud components update
	@gcloud auth login
	@gcloud auth configure-docker
	@gcloud services enable appengine.googleapis.com
	@gcloud services enable cloudscheduler.googleapis.com
	@gcloud services enable cloudfunctions.googleapis.com
	@gcloud services enable cloudbuild.googleapis.com
	@gcloud services enable containerregistry.googleapis.com
	@gcloud services enable run.googleapis.com

setup.bucket: setup
	@echo "Checking if bucket already exists..."
	@if ! gsutil ls -b gs://${GOOGLE_CLOUD_PROJECT}-reports > /dev/null 2>&1; then \
		echo "Creating bucket gs://${GOOGLE_CLOUD_PROJECT}-reports..."; \
		gsutil mb -c STANDARD -l US -b on gs://${GOOGLE_CLOUD_PROJECT}-reports; \
	else \
		echo "Bucket gs://${GOOGLE_CLOUD_PROJECT}-reports already exists. Skipping creation."; \
	fi

setup.firestore: setup
	@echo "Checking if App Engine application already exists..."
	@if ! gcloud app describe > /dev/null 2>&1; then \
		echo "Creating App Engine application..."; \
		gcloud app create --region=us-central; \
	else \
		echo "App Engine application already exists. Skipping creation."; \
	fi
	@echo "Checking if Firestore database already exists..."
	@if ! gcloud firestore databases list --format="value(name)" | grep -q "projects/${GOOGLE_CLOUD_PROJECT}/databases/(default)"; then \
		echo "Creating Firestore database..."; \
		gcloud firestore databases create --region=us-central; \
	else \
		echo "Firestore database already exists. Skipping creation."; \
	fi

setup.iam: setup
	@echo "Checking if service account already exists..."
	@if ! gcloud iam service-accounts describe tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com > /dev/null 2>&1; then \
		echo "Creating service account tide-run-server..."; \
		gcloud iam service-accounts create tide-run-server --display-name "Tide Cloud Run Server"; \
	else \
		echo "Service account tide-run-server already exists. Skipping creation."; \
	fi

# Setup for cross-platform Docker builds
setup.buildx:
	@docker buildx create --name wptide-builder --use || true
	@echo "Buildx builder 'wptide-builder' created and set as default"

setup.qemu:
	@docker run --privileged --rm tonistiigi/binfmt --install all
	@echo "QEMU emulation layers installed for cross-platform builds"

setup.crossplatform: setup.qemu setup.buildx
	@echo "Cross-platform build environment ready"

# Build commands using buildx with conditional platform flag
build.lighthouse:
	@docker buildx build $(PLATFORM_FLAG) --no-cache -t gcr.io/${GOOGLE_CLOUD_PROJECT}/lighthouse:${VERSION} -f ./app/docker/Dockerfile.lighthouse ./app --load

build.phpcs:
	@docker buildx build $(PLATFORM_FLAG) --no-cache -t gcr.io/${GOOGLE_CLOUD_PROJECT}/phpcs:${VERSION} -f ./app/docker/Dockerfile.phpcs ./app --load

build.sync:
	@docker buildx build $(PLATFORM_FLAG) --no-cache -t gcr.io/${GOOGLE_CLOUD_PROJECT}/sync:${VERSION} -f ./app/docker/Dockerfile.sync ./app --load

push.lighthouse:
	@docker push gcr.io/${GOOGLE_CLOUD_PROJECT}/lighthouse:${VERSION}

push.phpcs:
	@docker push gcr.io/${GOOGLE_CLOUD_PROJECT}/phpcs:${VERSION}

push.sync:
	@docker push gcr.io/${GOOGLE_CLOUD_PROJECT}/sync:${VERSION}

start.lighthouse:
	@docker run -v $(PWD)/app/src:/app/src -v $(PWD)/app/data:/app/data -v $(PWD)/app/service-account.json:/app/service-account.json --rm -p 5010:8080 --env-file .env.server gcr.io/${GOOGLE_CLOUD_PROJECT}/lighthouse:${VERSION}

start.phpcs:
	@docker run -v $(PWD)/app/src:/app/src -v $(PWD)/app/data:/app/data -v $(PWD)/app/service-account.json:/app/service-account.json --rm -p 5011:8080 --env-file .env.server gcr.io/${GOOGLE_CLOUD_PROJECT}/phpcs:${VERSION}

start.sync:
	@docker run -v $(PWD)/app/src:/app/src --rm -p 5012:8080 --env-file .env.server gcr.io/${GOOGLE_CLOUD_PROJECT}/sync:${VERSION}

deploy.api: setup
	@gcloud functions deploy api --source app --allow-unauthenticated --runtime nodejs18 --trigger-http --set-env-vars "NODE_ENV=production,GOOGLE_CLOUD_STORAGE_BUCKET_NAME=${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"

deploy.spec: setup
	@gcloud functions deploy spec --source app --allow-unauthenticated --runtime nodejs18 --trigger-http --set-env-vars "NODE_ENV=production,GOOGLE_CLOUD_STORAGE_BUCKET_NAME=${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"

deploy.firebase:
	@firebase --project=${GOOGLE_CLOUD_PROJECT} deploy --only hosting

deploy.firestore:
	@firebase --project=${GOOGLE_CLOUD_PROJECT} deploy --only firestore

deploy.lighthouse: setup
	@gcloud run deploy lighthouse-server --no-allow-unauthenticated --image gcr.io/${GOOGLE_CLOUD_PROJECT}/lighthouse:${VERSION} --memory ${GOOGLE_CLOUD_RUN_LIGHTHOUSE_MEMORY} --timeout 10m --concurrency 1 --set-env-vars "NODE_ENV=production,GOOGLE_CLOUD_STORAGE_BUCKET_NAME=${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"

deploy.phpcs: setup
	@gcloud run deploy phpcs-server --no-allow-unauthenticated --image gcr.io/${GOOGLE_CLOUD_PROJECT}/phpcs:${VERSION} --memory ${GOOGLE_CLOUD_RUN_PHPCS_MEMORY} --timeout 10m --concurrency 1 --set-env-vars "NODE_ENV=production,GOOGLE_CLOUD_STORAGE_BUCKET_NAME=${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"

deploy.sync: setup
	@gcloud run deploy sync-server --no-allow-unauthenticated --image gcr.io/${GOOGLE_CLOUD_PROJECT}/sync:${VERSION} --memory ${GOOGLE_CLOUD_RUN_SYNC_MEMORY} --timeout 10m --concurrency 1 --set-env-vars "NODE_ENV=production" --max-instances 1

deploy.iam: setup
	@echo "Checking if tide-run-server service account exists..."
	@if ! gcloud iam service-accounts describe tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com > /dev/null 2>&1; then \
		echo "Error: Service account tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com does not exist."; \
		echo "Please run 'make setup.iam' first and wait a few minutes for the service account to propagate."; \
		exit 1; \
	fi
	
	@echo "Adding IAM policy bindings to Cloud Run services..."
	@echo "Adding IAM policy binding to lighthouse-server..."
	@gcloud run services add-iam-policy-binding lighthouse-server \
		--member=serviceAccount:tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
		--role=roles/run.invoker || true
	
	@echo "Adding IAM policy binding to phpcs-server..."
	@gcloud run services add-iam-policy-binding phpcs-server \
		--member=serviceAccount:tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
		--role=roles/run.invoker || true
	
	@echo "Adding IAM policy binding to sync-server..."
	@gcloud run services add-iam-policy-binding sync-server \
		--member=serviceAccount:tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
		--role=roles/run.invoker || true
	
	@if [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER}" ]; then \
		echo "Adding IAM policy binding to project..."; \
		gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
			--member=serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
			--role=roles/iam.serviceAccountTokenCreator || true; \
	else \
		echo "Skipping IAM policy binding for project (GOOGLE_CLOUD_PROJECT_NUMBER not set)"; \
	fi
	
	@echo "IAM policy bindings added successfully."

deploy.topics: setup
	@echo "Setting up Pub/Sub topics..."
	
	@echo "Setting up MESSAGE_TYPE_LIGHTHOUSE_REQUEST topic..."
	@if ! gcloud pubsub topics describe MESSAGE_TYPE_LIGHTHOUSE_REQUEST > /dev/null 2>&1; then \
		gcloud pubsub topics create MESSAGE_TYPE_LIGHTHOUSE_REQUEST || true; \
	else \
		echo "Topic MESSAGE_TYPE_LIGHTHOUSE_REQUEST already exists. Skipping creation."; \
	fi
	
	@echo "Setting up MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER topic..."
	@if ! gcloud pubsub topics describe MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER > /dev/null 2>&1; then \
		gcloud pubsub topics create MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER || true; \
	else \
		echo "Topic MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER already exists. Skipping creation."; \
	fi
	
	@if [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER}" ]; then \
		echo "Adding IAM policy binding to MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER topic..."; \
		gcloud pubsub topics add-iam-policy-binding MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER \
			--member='serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com' \
			--role='roles/pubsub.publisher' || true; \
	else \
		echo "Skipping IAM policy binding for MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER topic (GOOGLE_CLOUD_PROJECT_NUMBER not set)"; \
	fi
	
	@echo "Setting up MESSAGE_TYPE_PHPCS_REQUEST topic..."
	@if ! gcloud pubsub topics describe MESSAGE_TYPE_PHPCS_REQUEST > /dev/null 2>&1; then \
		gcloud pubsub topics create MESSAGE_TYPE_PHPCS_REQUEST || true; \
	else \
		echo "Topic MESSAGE_TYPE_PHPCS_REQUEST already exists. Skipping creation."; \
	fi
	
	@echo "Setting up MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER topic..."
	@if ! gcloud pubsub topics describe MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER > /dev/null 2>&1; then \
		gcloud pubsub topics create MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER || true; \
	else \
		echo "Topic MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER already exists. Skipping creation."; \
	fi
	
	@if [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER}" ]; then \
		echo "Adding IAM policy binding to MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER topic..."; \
		gcloud pubsub topics add-iam-policy-binding MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER \
			--member='serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com' \
			--role='roles/pubsub.publisher' || true; \
	else \
		echo "Skipping IAM policy binding for MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER topic (GOOGLE_CLOUD_PROJECT_NUMBER not set)"; \
	fi
	
	@echo "Setting up MESSAGE_TYPE_SYNC_REQUEST topic..."
	@if ! gcloud pubsub topics describe MESSAGE_TYPE_SYNC_REQUEST > /dev/null 2>&1; then \
		gcloud pubsub topics create MESSAGE_TYPE_SYNC_REQUEST || true; \
	else \
		echo "Topic MESSAGE_TYPE_SYNC_REQUEST already exists. Skipping creation."; \
	fi
	
	@echo "Setting up MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER topic..."
	@if ! gcloud pubsub topics describe MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER > /dev/null 2>&1; then \
		gcloud pubsub topics create MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER || true; \
	else \
		echo "Topic MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER already exists. Skipping creation."; \
	fi
	
	@if [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER}" ]; then \
		echo "Adding IAM policy binding to MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER topic..."; \
		gcloud pubsub topics add-iam-policy-binding MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER \
			--member='serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com' \
			--role='roles/pubsub.publisher' || true; \
	else \
		echo "Skipping IAM policy binding for MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER topic (GOOGLE_CLOUD_PROJECT_NUMBER not set)"; \
	fi
	
	@echo "Pub/Sub topics setup completed successfully."

deploy.pubsub: setup.iam deploy.topics
	@echo "Checking if tide-run-server service account exists..."
	@if ! gcloud iam service-accounts describe tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com > /dev/null 2>&1; then \
		echo "Error: Service account tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com does not exist."; \
		echo "Please run 'make setup.iam' first and wait a few minutes for the service account to propagate."; \
		exit 1; \
	fi
	@echo "Service account exists. Proceeding with Pub/Sub setup..."
	
	@echo "Setting up lighthouse-server-dead-letter subscription..."
	@if ! gcloud pubsub subscriptions describe lighthouse-server-dead-letter > /dev/null 2>&1; then \
		gcloud pubsub subscriptions create lighthouse-server-dead-letter --topic MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER || true; \
	else \
		echo "Subscription lighthouse-server-dead-letter already exists. Skipping creation."; \
	fi
	
	@echo "Setting up lighthouse-server subscription..."
	@if ! gcloud pubsub subscriptions describe lighthouse-server > /dev/null 2>&1; then \
		gcloud pubsub subscriptions create lighthouse-server --topic MESSAGE_TYPE_LIGHTHOUSE_REQUEST \
			--push-endpoint=${GOOGLE_CLOUD_RUN_LIGHTHOUSE} \
			--ack-deadline 180 \
			--enable-message-ordering \
			--push-auth-service-account=tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
			--max-delivery-attempts 5 \
			--dead-letter-topic MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER \
			--max-retry-delay 10 \
			--min-retry-delay 1 || true; \
	else \
		echo "Subscription lighthouse-server already exists. Skipping creation."; \
	fi
	
	@if [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER}" ]; then \
		echo "Adding IAM policy binding to lighthouse-server subscription..."; \
		gcloud pubsub subscriptions add-iam-policy-binding lighthouse-server \
			--member=serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
			--role=roles/pubsub.subscriber || true; \
	else \
		echo "Skipping IAM policy binding for lighthouse-server subscription (GOOGLE_CLOUD_PROJECT_NUMBER not set)"; \
	fi
	
	@echo "Setting up phpcs-server-dead-letter subscription..."
	@if ! gcloud pubsub subscriptions describe phpcs-server-dead-letter > /dev/null 2>&1; then \
		gcloud pubsub subscriptions create phpcs-server-dead-letter --topic MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER || true; \
	else \
		echo "Subscription phpcs-server-dead-letter already exists. Skipping creation."; \
	fi
	
	@echo "Setting up phpcs-server subscription..."
	@if ! gcloud pubsub subscriptions describe phpcs-server > /dev/null 2>&1; then \
		gcloud pubsub subscriptions create phpcs-server --topic MESSAGE_TYPE_PHPCS_REQUEST \
			--push-endpoint=${GOOGLE_CLOUD_RUN_PHPCS} \
			--ack-deadline 180 \
			--enable-message-ordering \
			--push-auth-service-account=tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
			--max-delivery-attempts 5 \
			--dead-letter-topic MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER \
			--max-retry-delay 10 \
			--min-retry-delay 1 || true; \
	else \
		echo "Subscription phpcs-server already exists. Skipping creation."; \
	fi
	
	@if [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER}" ]; then \
		echo "Adding IAM policy binding to phpcs-server subscription..."; \
		gcloud pubsub subscriptions add-iam-policy-binding phpcs-server \
			--member=serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
			--role=roles/pubsub.subscriber || true; \
	else \
		echo "Skipping IAM policy binding for phpcs-server subscription (GOOGLE_CLOUD_PROJECT_NUMBER not set)"; \
	fi
	
	@echo "Setting up sync-server-dead-letter subscription..."
	@if ! gcloud pubsub subscriptions describe sync-server-dead-letter > /dev/null 2>&1; then \
		gcloud pubsub subscriptions create sync-server-dead-letter --topic MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER || true; \
	else \
		echo "Subscription sync-server-dead-letter already exists. Skipping creation."; \
	fi
	
	@echo "Setting up sync-server subscription..."
	@if ! gcloud pubsub subscriptions describe sync-server > /dev/null 2>&1; then \
		gcloud pubsub subscriptions create sync-server --topic MESSAGE_TYPE_SYNC_REQUEST \
			--push-endpoint=${GOOGLE_CLOUD_RUN_SYNC} \
			--ack-deadline 180 \
			--push-auth-service-account=tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
			--max-delivery-attempts 5 \
			--dead-letter-topic MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER \
			--max-retry-delay 10 \
			--min-retry-delay 1 || true; \
	else \
		echo "Subscription sync-server already exists. Skipping creation."; \
	fi
	
	@if [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER}" ]; then \
		echo "Adding IAM policy binding to sync-server subscription..."; \
		gcloud pubsub subscriptions add-iam-policy-binding sync-server \
			--member=serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
			--role=roles/pubsub.subscriber || true; \
	else \
		echo "Skipping IAM policy binding for sync-server subscription (GOOGLE_CLOUD_PROJECT_NUMBER not set)"; \
	fi
	
	@echo "Pub/Sub setup completed successfully."

deploy.scheduler: setup
	@echo "Setting up Cloud Scheduler job..."
	@if ! gcloud scheduler jobs describe sync-server > /dev/null 2>&1; then \
		echo "Creating scheduler job sync-server..."; \
		gcloud scheduler jobs create pubsub sync-server --schedule "*/5 * * * *" --topic MESSAGE_TYPE_SYNC_REQUEST --message-body "Start Sync/Ingest" --max-retry-attempts 0 || true; \
	else \
		echo "Scheduler job sync-server already exists. Skipping creation."; \
	fi
	@echo "Cloud Scheduler job setup completed successfully."

describe.lighthouse: setup
	@gcloud run services describe lighthouse-server --format 'value(status.url)'

describe.phpcs: setup
	@gcloud run services describe phpcs-server --format 'value(status.url)'

describe.sync: setup
	@gcloud run services describe sync-server --format 'value(status.url)'

delete.files:
	@echo "Deleting files from bucket..."
	@echo "Using bucket: ${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"
	@BUCKET_NAME="${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"; \
	if [[ ! $$BUCKET_NAME == gs://* ]]; then \
		BUCKET_NAME="gs://$$BUCKET_NAME"; \
	fi; \
	echo "Bucket name: $$BUCKET_NAME"; \
	if gsutil ls -b $$BUCKET_NAME > /dev/null 2>&1; then \
		echo "Bucket $$BUCKET_NAME exists."; \
		gsutil -o "GSUtil:parallel_process_count=1" rm -r $$BUCKET_NAME/** 2>/dev/null || true; \
		echo "Files deleted from bucket."; \
	else \
		echo "Bucket $$BUCKET_NAME does not exist. Skipping."; \
	fi

delete.firestore:
	@firebase --project=${GOOGLE_CLOUD_PROJECT} firestore:delete --force --all-collections

delete.scheduler:
	@gcloud scheduler jobs delete sync-server --quiet || true

# Destroy targets for tearing down infrastructure
destroy.pubsub:
	@echo "Deleting Pub/Sub subscriptions..."
	@gcloud pubsub subscriptions delete lighthouse-server --quiet || true
	@gcloud pubsub subscriptions delete lighthouse-server-dead-letter --quiet || true
	@gcloud pubsub subscriptions delete phpcs-server --quiet || true
	@gcloud pubsub subscriptions delete phpcs-server-dead-letter --quiet || true
	@gcloud pubsub subscriptions delete sync-server --quiet || true
	@gcloud pubsub subscriptions delete sync-server-dead-letter --quiet || true
	@echo "Pub/Sub subscriptions deleted successfully."

destroy.topics:
	@echo "Deleting Pub/Sub topics..."
	@gcloud pubsub topics delete MESSAGE_TYPE_LIGHTHOUSE_REQUEST --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_PHPCS_REQUEST --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_SYNC_REQUEST --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER --quiet || true
	@echo "Pub/Sub topics deleted successfully."

destroy.services:
	@echo "Deleting Cloud Run services..."
	@gcloud run services delete lighthouse-server --quiet || true
	@gcloud run services delete phpcs-server --quiet || true
	@gcloud run services delete sync-server --quiet || true
	@echo "Cloud Run services deleted successfully."

destroy.functions:
	@echo "Deleting Cloud Functions..."
	@gcloud functions delete api --quiet || true
	@gcloud functions delete spec --quiet || true
	@echo "Cloud Functions deleted successfully."

destroy.iam:
	@echo "Deleting IAM service accounts..."
	@gcloud iam service-accounts delete tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --quiet || true
	@gcloud iam service-accounts delete local-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --quiet || true
	@echo "IAM service accounts deleted successfully."

destroy.bucket:
	@echo "Deleting Cloud Storage bucket..."
	@gsutil -m rm -r gs://${GOOGLE_CLOUD_PROJECT}-reports/** || true
	@gsutil rb -f gs://${GOOGLE_CLOUD_PROJECT}-reports || true
	@echo "Cloud Storage bucket deleted successfully."

destroy.scheduler:
	@echo "Deleting Cloud Scheduler job..."
	@gcloud scheduler jobs delete sync-server --quiet || true
	@echo "Cloud Scheduler job deleted successfully."

destroy: destroy.pubsub destroy.topics destroy.services destroy.functions destroy.scheduler destroy.iam destroy.bucket
	@echo "All infrastructure has been torn down successfully."

download.keys: setup
	@echo "Checking if local-server service account already exists..."
	@if ! gcloud iam service-accounts describe local-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com > /dev/null 2>&1; then \
		echo "Creating local-server service account..."; \
		gcloud iam service-accounts create local-server --display-name "Local Development Server"; \
		echo "Adding IAM policy binding..."; \
		gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
			--member="serviceAccount:local-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
			--role=roles/owner; \
	else \
		echo "Service account local-server already exists. Skipping creation."; \
	fi
	@echo "Creating new service account key..."
	@gcloud iam service-accounts keys create app/service-account.json \
		--iam-account=local-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com

# Destroy commands - use with caution as they permanently delete resources

destroy.cloudrun: setup
	@echo "\033[0;31mWARNING: This will delete all Cloud Run services. Are you sure? (y/n)\033[0m"
	@read -p "" confirm && [ "$$confirm" = "y" ] || exit 1
	@gcloud run services delete lighthouse-server --quiet || true
	@gcloud run services delete phpcs-server --quiet || true
	@gcloud run services delete sync-server --quiet || true
	@echo "Cloud Run services deleted."

destroy.functions: setup
	@echo "\033[0;31mWARNING: This will delete all Cloud Functions. Are you sure? (y/n)\033[0m"
	@read -p "" confirm && [ "$$confirm" = "y" ] || exit 1
	@gcloud functions delete api --quiet || true
	@gcloud functions delete spec --quiet || true
	@echo "Cloud Functions deleted."

destroy.pubsub: setup
	@echo "\033[0;31mWARNING: This will delete all Pub/Sub topics and subscriptions. Are you sure? (y/n)\033[0m"
	@read -p "" confirm && [ "$$confirm" = "y" ] || exit 1
	@gcloud pubsub subscriptions delete lighthouse-server --quiet || true
	@gcloud pubsub subscriptions delete lighthouse-server-dead-letter --quiet || true
	@gcloud pubsub subscriptions delete phpcs-server --quiet || true
	@gcloud pubsub subscriptions delete phpcs-server-dead-letter --quiet || true
	@gcloud pubsub subscriptions delete sync-server --quiet || true
	@gcloud pubsub subscriptions delete sync-server-dead-letter --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_LIGHTHOUSE_REQUEST --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_LIGHTHOUSE_REQUEST_DEAD_LETTER --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_PHPCS_REQUEST --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_PHPCS_REQUEST_DEAD_LETTER --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_SYNC_REQUEST --quiet || true
	@gcloud pubsub topics delete MESSAGE_TYPE_SYNC_REQUEST_DEAD_LETTER --quiet || true
	@echo "Pub/Sub topics and subscriptions deleted."

destroy.iam: setup
	@echo "\033[0;31mWARNING: This will delete IAM service accounts and bindings. Are you sure? (y/n)\033[0m"
	@read -p "" confirm && [ "$$confirm" = "y" ] || exit 1
	@gcloud projects remove-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
		--member=serviceAccount:service-${GOOGLE_CLOUD_PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
		--role=roles/iam.serviceAccountTokenCreator || true
	@gcloud iam service-accounts delete tide-run-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --quiet || true
	@gcloud iam service-accounts delete local-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --quiet || true
	@echo "IAM service accounts and bindings deleted."

destroy.firebase: setup
	@echo "\033[0;31mWARNING: This will delete Firebase hosting configuration. Are you sure? (y/n)\033[0m"
	@read -p "" confirm && [ "$$confirm" = "y" ] || exit 1
	@firebase --project=${GOOGLE_CLOUD_PROJECT} hosting:disable --force || true
	@echo "Firebase hosting configuration deleted."

destroy.bucket: setup
	@echo "\033[0;31mWARNING: This will delete the Cloud Storage bucket. Are you sure? (y/n)\033[0m"
	@read -p "" confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "Using bucket: ${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"
	@gsutil rb "gs://${GOOGLE_CLOUD_STORAGE_BUCKET_NAME}"

destroy.appengine: setup
	@echo "\033[0;31mWARNING: This will attempt to disable App Engine. Are you sure? (y/n)\033[0m"
	@read -p "" confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "Note: App Engine cannot be fully deleted, but we'll attempt to disable it."
	@gcloud app services delete default --quiet || true
	@echo "App Engine services deleted (App Engine itself cannot be fully removed from a project)."

# Master destroy command that runs all individual destroy commands in the appropriate order
destroy: setup
	@echo "\033[0;31mWARNING: This will destroy ALL GCP resources created by this project. This action is IRREVERSIBLE.\033[0m"
	@echo "\033[0;31mAre you absolutely sure you want to proceed? Type 'yes' to confirm:\033[0m"
	@read -p "" confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "\033[0;31mStarting destruction of all resources...\033[0m"
	@$(MAKE) delete.scheduler || true
	@$(MAKE) destroy.pubsub || true
	@$(MAKE) destroy.cloudrun || true
	@$(MAKE) destroy.functions || true
	@$(MAKE) destroy.firebase || true
	@$(MAKE) delete.firestore || true
	@$(MAKE) destroy.bucket || true
	@$(MAKE) destroy.iam || true
	@$(MAKE) destroy.appengine || true
	@echo "\033[0;32mAll resources have been destroyed.\033[0m"
