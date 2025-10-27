from motor.motor_inferencia import Motor_inferencia
from interface.cli import Interface


def main():
    motor_inferencia = Motor_inferencia()
    interface = Interface(motor_inferencia)
    interface.start()


if __name__ == "__main__":  
    main()