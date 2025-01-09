# Open original file for reconstruction
fileM = open("/tmp/areplicate-2024.5.0-144.rpm", "wb")

# Manually enter total amount of "chunks"
chunk = 0
chunks = 2

bytesRead = 90000000
chunkName = "/tmp/areplicate-2024.5.0-144_bin"


# Piece the file together using all chunks
while chunk <= chunks:
    print(" - Chunk #" + str(chunk) + " done.")
    fileName = f'{chunkName}-{chunk:0>2}.byte'
    fileTemp = open(fileName, "rb")

    byte = fileTemp.read(bytesRead)
    fileM.write(byte)

    chunk += 1

fileM.close()