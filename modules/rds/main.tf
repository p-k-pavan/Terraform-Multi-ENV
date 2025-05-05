resource "aws_db_subnet_group" "default" {
  name = "${var.name}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-rds-subnet-group"
    Environment = var.env
  }
}

resource "aws_db_instance" "main" {
  allocated_storage = 10
  db_name = var.db_name
  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  username = var.username
  password = var.password
  skip_final_snapshot = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
    Environment = var.env
  }

}