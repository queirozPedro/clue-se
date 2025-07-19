from motor.base_conhecimento import Base_conhecimento
from motor.motor_inferencia import Motor_inferencia
from interface.cli import Interface


def main():
    base_conhecimento = Base_conhecimento("base_conhecimento.pl")
    motor_inferencia = Motor_inferencia(base_conhecimento)
    interface = Interface(motor_inferencia)
    interface.start()

if __name__ == "__main__":
    main()
