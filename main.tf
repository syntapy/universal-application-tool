# Filename: main.tf
# Configure GCP project
provider "google" {
  credentials = file("credentials.json")
  project = var.project_id 
}
# Deploy image to Cloud Run
resource "google_cloud_run_service" "uat" {
  name     = "uat"
  location = "us-west1"
  template {
    spec {
      containers {
        image = join("", ["gcr.io/", var.project_id, "/uat"])
        #ports {
        #  container_port = 9000
        #}
        resources {
          limits = {memory = "2048M"}
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "postgres" {
  name     = "postgres"
  location = "us-west1"
  template {
    spec {
      containers {
        image = join("", ["gcr.io/", var.project_id, "/postgres"])
        env {
          name = "POSTGRES_PASSWORD"
          value = "example"
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "adminer" {
  name     = "adminer"
  location = "us-west1"
  template {
    spec {
      containers {
        image = join("", ["gcr.io/", var.project_id, "/adminer"])
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Create public access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
# Enable public access on Cloud Run service
resource "google_cloud_run_service_iam_policy" "uat_auth" {
  location    = google_cloud_run_service.uat.location
  project     = google_cloud_run_service.uat.project
  service     = google_cloud_run_service.uat.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service_iam_policy" "adminer_auth" {
  location    = google_cloud_run_service.adminer.location
  project     = google_cloud_run_service.adminer.project
  service     = google_cloud_run_service.adminer.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service_iam_policy" "postgres_auth" {
  location    = google_cloud_run_service.postgres.location
  project     = google_cloud_run_service.postgres.project
  service     = google_cloud_run_service.postgres.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# Return service URL
output "url_uat" {
  value = google_cloud_run_service.uat.status[0].url
}

output "url_adminer" {
  value = google_cloud_run_service.adminer.status[0].url
}
