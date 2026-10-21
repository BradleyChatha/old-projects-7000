///This is an example of shorter but slower
vector<int> myVector; 
myVector.resize(1024); ///Array of 1024 integers

for(int i = 0; i < myVector.size(); i++)
{
    ///Carry out operations
}

///Example of longer but faster code
vector<int> myVector; 
myVector.resize(1024); ///Array of 1024 integers
size_t myVectorSize = myVector.size();

for(int i = 0; i < myVectorSize; i++)
{
    ///Carry out operations
}