from controlador.controlador import Controlador
from interface.interface import Interface


def main():
    controlador = Controlador()
    interface = Interface(controlador)
    interface.start()


if __name__ == "__main__":  
    main()