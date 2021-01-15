provider "google" {
    version = "3.5.0"
    credentials = file("credentials.json")
    project = "decoded-indexer-301503"
    region = "us-central1"
    zone = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
    name = "terraform-instance"
    machine_type = "f1-micro"
    tags = ["web", "dev"]

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
        }
    }
    
    network_interface {
        network = google_compute_network.vpc_network.self_link
        access_config {
            nat_ip = google_compute_address.vm_static_ip.address
        }
    }


    provisioner "file" {
        source      = "compose-app/"
        destination = "/code"
    }

    provisioner "remote-exec" {
        inline = [
            "cd /code",
            "docker-compose up",
        ]
    } 
}

resource "google_compute_network" "vpc_network" {
    name = "terraform-network"
}

resource "google_compute_address" "vm_static_ip" {
    name = "terraform-static-ip"
}
