resource "digitalocean_droplet" "elasticsearch" {
  image  = "elasticsearch"
  name   = "elk-stack-elasticsearch"
  region = var.region
  size   = var.droplet_size_slug
  ssh_keys = var.ssh_key_ids
  tags = [for k, v in digitalocean_tag.tags : v.id]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    agent = true
    timeout = "7m"
  }

  user_data = <<-EOF
    #!/bin/bash

    echo "Waiting for ElastiсSearch service to become active" >> /var/log/user_data.log

    while ! [ "$(systemctl is-active elasticsearch.service)" = "active" ]; do
      echo "." >> /var/log/user_data.log
      sleep 10
    done

    echo "ElasticSearch is active. Starting setup" >> /var/log/user_data.log

    sleep 30

    . /root/.digitalocean_passwords

    echo "Overwriting Kibana password env" >> /var/log/user_data.log

    cat > /root/.digitalocean_passwords <<EOM
    ELASTIC_PASSWORD=$${ELASTIC_PASSWORD}
    KIBANA_PASSWORD=${random_password.password.result}
    LOGSTASH_SYSTEM_PASSWORD=$${LOGSTASH_SYSTEM_PASSWORD}
    KIBANA_ENROLLMENT_TOKEN=$${KIBANA_ENROLLMENT_TOKEN}
    EOM

    echo "Updating ElasticSearch config" >> /var/log/user_data.log

    cat > /etc/elasticsearch/elasticsearch.yml <<EOM
    path.data: /var/lib/elasticsearch
    path.logs: /var/log/elasticsearch
    xpack.security.enabled: true

    http.host: 0.0.0.0
    network.host: 0.0.0.0

    discovery.type: single-node
    EOM

    echo "Refreshing ElasticSearch keystore" >> /var/log/user_data.log

    rm /etc/elasticsearch/elasticsearch.keystore
    /usr/share/elasticsearch/bin/elasticsearch-keystore create

    echo "Restarting Elastic" >> /var/log/user_data.log

    systemctl restart elasticsearch

    sleep 10

    echo "Resetting Kibana user password via ElasticSearch API" >> /var/log/user_data.log

    . /root/.digitalocean_passwords

    kibana_payload=$(printf '{"password": "%s"}' "$KIBANA_PASSWORD")

    curl -uelastic:"$${ELASTIC_PASSWORD}" -XPOST -H 'Content-Type: application/json' 'http://0.0.0.0:9200/_security/user/kibana/_password?pretty' -d "$kibana_payload" >> /var/log/user_data_curl.log

    echo "Kibana user password is set, restarting ElasticSearch" >> /var/log/user_data.log

    systemctl restart elasticsearch

    echo "Done. Enjoy your ELK stack!" >> /var/log/user_data.log

    EOF
}
