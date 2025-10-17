provider "aws" {
  region = "us-east-1"  # Cambia según tu región
}

resource "aws_instance" "flask_server" {
  ami           = "ami-0360c520857e3138f"  # Ubuntu 22.04 LTS en us-east-1
  instance_type = "t2.micro"
  key_name      = "llaveMajo"  # Asegúrate de que esta key exista en tu cuenta AWS

  # Script de inicio para instalar Flask y correr la app
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install python3-pip -y
              pip3 install Flask==2.3.2
              cat <<EOT >> /home/ubuntu/app.py
              from flask import Flask
              app = Flask(__name__)
              @app.route("/")
              def hello():
                  return "Hola Mundo desde Flask en EC2!"
              if __name__ == "__main__":
                  app.run(host="0.0.0.0", port=80)
              EOT
              nohup python3 /home/ubuntu/app.py &
              EOF

  tags = {
    Name = "FlaskServer"
  }

  # Asocia el grupo de seguridad
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
}

resource "aws_security_group" "flask_sg" {
  name        = "flask_sg"
  description = "Allow HTTP"

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Todo el tráfico de salida permitido
    cidr_blocks = ["0.0.0.0/0"]
  }
}
