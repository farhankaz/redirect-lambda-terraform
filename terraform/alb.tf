resource "aws_security_group" "lb_sg" {
  name        = "fk-acclaim-302-lb-sq"
  description = "Security group for ALB for fk-acclaim-302"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPs from all"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "lb-tg-fk-acclaim-302-lambda"
  target_type = "lambda"
}


resource "aws_lambda_permission" "allow_alb" {
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.tg.arn
}

resource "aws_lb_target_group_attachment" "tga" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_lambda_function.redirect_lambda.arn
  depends_on       = [aws_lambda_permission.allow_alb]
}

resource "aws_lb" "redirect_lb" {
  name               = "fk-acclaim-302-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_listener" "http_redirect_listener" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  # Redirect HTTP to server root only to ensure user cannot be transparently using service via HTTP but can still
  # access the site for the first time by typing app.narrative.io without speciying a protocol.
  default_action {
    type = "redirect"
    redirect {
      path        = "/"
      port        = 443
      protocol    = "HTTPS"
      query       = ""
      status_code = "HTTP_301"
    }
  }
}
