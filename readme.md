# Imagen de docker con el simulador NS3 y el módulo NR Lena-5G

Para crear la imagen:

```
docker build . -t "5g-lena"
```

Para crear un container

```
docker run -d -t 5g-lena --name "curso_redes_moviles_facet_unt_2023"
```

En VS Code instalar plugins Docker y Dev Containers. Luego, desde el plugin
Docker iniciar el container si no se está ejecutando, hacer click derecho sobre
el mismo y elegir `Attach Visual Studio Code`
