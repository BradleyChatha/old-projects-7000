import io
import string

def readFile() -> str:
    toReturn = ""

    with open("TokenType.h", mode="r") as f:
        for line in f.readlines():
            toReturn += line

    return toReturn

def findNames(code: str) -> list:
    names = []
    splitted = code.splitlines()

    i = 0
    search = False
    for line in splitted:
        if "enum class TokenType" in line:
            search = True
        elif "{" in line and search:
            i += 1
            continue
        elif "}" in line and search:
            search = False
        elif search and not line.strip().startswith("//"):
            names.append(line.strip().split(' ')[0].strip(','))

        i += 1

    return names

def makeCode(code: str, names: list) -> str:
    splitted = code.splitlines()
    toInsert = "namespace" \
               "\n{\n" \
               "\tconst static string[] TokenTypeNames = {"

    i = 0
    for name in names:
        toInsert += '"%s"' % (name)

        if i != len(names)-1:
            toInsert += ", "

        i += 1

    toInsert += "};\n}"
    return toInsert

def makePatch(orig: str, code: str) -> str:
    splitted = orig.splitlines()

    i = 0
    for line in splitted:
        if line.startswith("namespace"):
            break

        i += 1

    splitted.insert(i, code)
    output = "\n".join(splitted)
    return output

def mainFunc():
    original = readFile()
    names = findNames(original)
    code = makeCode(original, names)
    patch = makePatch(original, code)

    with open("Lexer_Patched.h", mode="w") as f:
        f.write(patch)

if __name__ == '__main__':
    mainFunc()
