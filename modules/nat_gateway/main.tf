resource "aws_eip" "nat" {
  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-nat-gw"
    }
  )

  depends_on = [var.dependency_igw]  # 👈 Ensures IGW is created first
}
