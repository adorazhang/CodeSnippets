#include <iostream>
#include <cstring>
#include <vector>

using namespace std;

class set
{
public:
    int id; // Number of each atom in clause set
    string str; // Clause set atom content
};

const unsigned int MAX_SIZE = 1000; // Max size of clause set
unsigned int size; // Actual size of clause set
unsigned int tmpsize; // A temporary copy of cla use set size
unsigned int prenum; // Number of predicates

char p[MAX_SIZE]; // Predicates array
set s[MAX_SIZE]; // Clause set array

bool numeration(); // Numeration Resolution Method
bool deletion(); // Deletion Strategy Resolution Method
bool support(); // Support Vector Machine Resolution Method
bool single(); // Single Atom Resolution Method
string apodosis(string, string, int); // Apodosis two clauses
int have_contradiction(set, set); // Check if two clauses have contradictions
vector<string> split(string); // Split a string into substring vectors
vector<string> check_overlap(vector<string>, vector<string>); // Check if two clauses are overlapped after opodosis
string tostring(vector<string> v); // Convert substring vectors back to a string
bool substitute(char,char); // Check if we can substitute x with a
bool pure_literal(int); // Check if a clause is a pure literal

int main()
{
    cout << "Input Predicates: (Consists of upper class characters i.e. [A-Z])" << endl;
    cout << "e.g. P, Q. One predicate per line. End input with a single #" << endl;
    int i = 0;
    while(cin >> p[i] && p[i++] != '#');
    prenum = i-2;
    //cout<<prenum<<endl;

    /////////////////////////////////////////////////

    cout << "Input Clause Set: (Only permits one lower class character: a, b, c, x, y, z)" << endl;
    cout << "e.g. P(x), ~Q(a), P(x)|Q(x). One item per line. End input with a single #" << endl;
    i = 0;
    while(cin >> s[i].str && s[i].str != "#")
    {
        s[i].id = i;
        i++;
    }
    size = i-1;
    //cout<<size<<endl;

    /////////////////////////////////////////////////

    cout << "\n��ٲ��ԣ�" << endl;
    if ( numeration() )
        cout << "�������Ӿ䣬������" << endl;
    else
        cout << "δ�������Ӿ䣬���ʧ��" << endl;

    cout << endl;
    cout << "֧�ּ������ԣ�" << endl;
    if ( support() )
        cout << "�������Ӿ䣬������" << endl;
    else
        cout << "δ�������Ӿ䣬���ʧ��" << endl;


    cout << endl;
    cout << "�����ֹ����ԣ�" << endl;
    if ( single() )
        cout << "�������Ӿ䣬������" << endl;
    else
        cout << "δ�������Ӿ䣬���ʧ��" << endl;

    cout << endl;
    cout << "ɾ�����ԣ�" << endl;
    if ( deletion() )
        cout << "�������Ӿ䣬������" << endl;
    else
        cout << "δ�������Ӿ䣬���ʧ��" << endl;


    return 0;
}

int have_contradiction(set a, set b)
{
    int s1 , s2;
    for(int i=0; i <= prenum; i++) // for each p[i]
    {
        if( a.str.find(p[i])!=string::npos && b.str.find(p[i])!=string::npos ) // if p[i] in clause a && b
        {
            s1 = a.str.find(p[i]);
            s2 = b.str.find(p[i]);
            if ( ( a.str[s1-1] == '~' && b.str[s2-1] != '~' ) || ( a.str[s1-1] != '~' && b.str[s2-1] == '~' ) )
            {
                if( ( ( a.str[s1+2]<='c' && b.str[s2+2]<='c' ) || ( a.str[s1+2]>='x' && b.str[s2+2]>='x' ) ) && a.str[s1+2]!=b.str[s2+2] ) // if a contains p(a) && b contains ~p(b)
                    return -1;
                else
                    return i;
            }
            else return -1;
        }
    }
    return -1;
}

bool substitute(char a, char b)
{
    if( (a=='a'||a=='b'||a=='c')&&(b=='x'||b=='y'||b=='z') )
        return true;
    else if( (a=='x'||a=='y'||a=='z')&&(b=='a'||b=='b'||b=='c') )
        return true;
    else if( (a=='a'||a=='b'||a=='c')&&(b=='a'||b=='b'||b=='c') )
        return false;
    else if( (a=='x'||a=='y'||a=='z')&&(b=='x'||b=='y'||b=='z') )
        return false;
}

vector<string> split(string text)
{
    vector<string> vec;
    string word;

    while(1)
    {
        int pos = text.find('|');
        if( pos==0 )
        {
            text=text.substr(1);
            continue;
        }
        if( pos<0 )
        {
            vec.push_back(text);
            break;
        }
        word = text.substr(0,pos);
        text = text.substr(pos+1);
        vec.push_back(word);
    }
    return vec;
}

vector<string> check_overlap(vector<string> v1, vector<string> v2)
{
    if(v1.size() != 0)
    {
        for(int i = 0; i < v1.size(); i++)
        {
            for(int j = 0; j < v2.size(); j++)
            {
                if(v1[i]==v2[j])
                {
                    v1.erase(v1.begin()+i);
                    i--;
                    if (i<0) i++;
                    if (i==v1.size()) break;
                }
            }
        }
    }
    else
    {
        return v2;
    }
    for(int i = 0; i < v1.size(); i++)
    {
        v2.push_back(v1[i]);
    }
    return v2;
}

string tostring(vector<string> v)
{
    string s=v[0];
    for(int i = 1; i < v.size(); i++)
    {
        s=s+"|"+v[i];
    }
    return s;
}

string apodosis(set a, set b, int k)
{
    string ans = "",display;
    vector<string> v1 = split(a.str), v2 = split(b.str);
    int p1 = a.str.find(p[k]) , p2 = b.str.find(p[k]);
    vector<string> t;

    if( a.str[p1+2] == b.str[p2+2] ) // case like P(a) and ~P(a)
    {
        for(int i = 0; i < v1.size(); i++)
        {
            for(int j = 0; j < v2.size(); j++)
            {
                if(( v1[i][0] == p[k] && v2[j][1] == p[k] ) ||
                        ( v1[i][1] == p[k] && v2[j][0] == p[k] ) )
                {
                    v1.erase(v1.begin()+i);
                    i--;
                    v2.erase(v2.begin()+j);
                    j--;
                    if (j<0) j++;
                    if (j==v2.size()) break;
                    t = check_overlap(v1,v2);
                    ans = tostring(t);
                }
            }
        }
        cout << "���[" << a.id << "]���Ӿ�" << a.str << "��[" << b.id << "]���Ӿ�" << b.str << "�õ�[" << tmpsize << "]���Ӿ�" << ans << "" << endl;
    }
    else if( substitute(a.str[p1+2],b.str[p2+2]) ) // case like P(a) and ~P(x)
    {
        string lower,upper;
        switch(a.str[p1+2])
        {
        case 'a':
        case 'b':
        case 'c':
            lower = a.str[p1+2];
            upper = b.str[p2+2];
            break;
        case 'x':
        case 'y':
        case 'z':
            lower = b.str[p2+2];
            upper = a.str[p1+2];
            break;
        }

        for(int i = 0; i < v1.size(); i++)
        {
            for(int j = 0; j < v2.size(); j++)
            {
                if(( v1[i][0] == p[k] && v2[j][1] == p[k] ) ||
                        ( v1[i][1] == p[k] && v2[j][0] == p[k] ) )
                {
                    v1.erase(v1.begin()+i);
                    i--;
                    if (i<0) i++;
                    if (i==v1.size()) break;
                    v2.erase(v2.begin()+j);
                    j--;
                    t = check_overlap(v1,v2);
                    ans = tostring(t);
                }
            }
        }
        if(ans == "") ans = "NULL";
        display = "�滻{"+lower+"/"+upper+"}��";
        cout << "���[" << a.id << "]���Ӿ�" << a.str << "��[" << b.id << "]���Ӿ�" << b.str << "��"<<display<<"�õ�[" << tmpsize << "]���Ӿ�" << ans << endl;
    }
    if ( ans == "NULL" ) ans = "";
    return ans;
}

bool numeration()
{
    tmpsize = size + 1;
    for (int i = 0; i < tmpsize; i++)
    {
        for (int j = i+1; j < tmpsize; j++)
        {
            if ( have_contradiction(s[i],s[j]) == -1 ) // These two atoms don't have contradiction with each other
            {
                continue;
            }
            else // These two atoms have contradiction with each other
            {
                s[tmpsize].id = tmpsize;
                s[tmpsize].str = apodosis( s[i] , s[j] , have_contradiction(s[i],s[j]) );
                if(s[tmpsize].str == "") return true;
                else
                {
                    tmpsize++;
                }
            }
        }
    }
    return false;
}

bool pure_literal( int k )
{
    vector<string> v;
    for(int i = 0; i < size; i++)
    {
        v = split( s[i].str );
        for(int j = 0; j < v.size(); j++)
        {
            if( v[j][0]=='~' && p[k] == v[j][1] ) return false;
        }
    }
    return true;
}
bool support()
{
    // ע�⣬���ֹ�᷽��Ҫ���������룬������Ϊ"ǰ��"��"���۵ķ�"����ʽ���� A1^A2^A3^A4^~A1ʱ�����걸��
    tmpsize = size + 1;
    tmpsize = size + 1;
    for (int i = 0; i < tmpsize-1; i++)
    {
        if ( have_contradiction(s[i],s[size]) == -1 ) // These two atoms don't have contradiction with each other
        {
            continue;
        }
        else // These two atoms have contradiction with each other
        {
            s[tmpsize].id = tmpsize;
            s[tmpsize].str = apodosis( s[i] , s[size] , have_contradiction(s[i],s[size]) );
            if(s[tmpsize].str == "") return true;
            else
            {
                tmpsize++;
            }
        }
    }
    return false;
}

bool single()
{
    tmpsize = size + 1;
    for (int i = 0; i < tmpsize; i++)
    {
        if( split(s[i].str).size() > 1 ) continue; // Requirement
        for (int j = i+1; j < tmpsize; j++)
        {
            if ( have_contradiction(s[i],s[j]) == -1 ) // These two atoms don't have contradiction with each other
            {
                continue;
            }
            else // These two atoms have contradiction with each other
            {
                s[tmpsize].id = tmpsize;
                s[tmpsize].str = apodosis( s[i] , s[j] , have_contradiction(s[i],s[j]) );
                if(s[tmpsize].str == "") return true;
                else
                {
                    tmpsize++;
                }
            }
        }
    }
    return false;
}

bool deletion()
{
    for(int i=0; i<prenum; i++)
    {
        if( pure_literal(i) )
        {
            cout << "ɾ����[" << s[i].id << "]���Ӿ䣬Ϊ����ʽ" << endl;
            s[i]=s[size--];
        }
    }
    numeration();
}
