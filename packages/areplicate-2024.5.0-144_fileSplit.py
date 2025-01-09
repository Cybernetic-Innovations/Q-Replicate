import os


def splitPackage(packagePath: str = None):
    # parse path to get path, filename and ext as json
    _path = parsePath(_packagePath)

    # File to open and break apart
    try:
        fileR = open(packagePath, "rb")
        bytesRead = 90000000
        chunkName = f'{_path["filename"]}_bin'
        chunk = 0

        byte = fileR.read(bytesRead)
        while byte:
            # Open a temporary file and write a chunk of bytes
            fileN = f'{chunkName}-{chunk:0>2}.byte'
            fileT = open(fileN, "wb")
            fileT.write(byte)
            fileT.close()

            # Read next {bytesRead} bytes
            byte = fileR.read(bytesRead)

            chunk += 1
        return {"splitPackage": {
            "directory": _path["directory"],
            "filename": _path["filename"],
            "extension": _path["extension"],
            "chunks": chunk
        }}

    except FileNotFoundError as exception:
        print(exception)


def parsePath(filePath: str = None):
    # Split the path into directory and filename with extension
    directory, filename_with_extension = os.path.split(filePath)

    # Split the filename and extension
    file, extension = os.path.splitext(filename_with_extension)

    return {
        "directory": directory,
        "filename": file,
        "extension": extension
    }


if __name__ == '__main__':
    _packagePath = "src/areplicate-2024.5.0-144.rpm"

    print(splitPackage(_packagePath))
