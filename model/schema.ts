import casual_impl = require('casual');

class Casual
{
  get first_name(): string
  {
    return casual_impl.first_name;
  }

  get last_name(): string
  {
    return casual_impl.last_name;
  }

  get email(): string
  {
    return casual_impl.email;
  }

  user(): {
    firstName: string;
    lastName: string;
    emails: Array<{
      address: string;
      verified: boolean
    }>
  }
  {
    return {
      firstName: this.first_name,
      lastName: this.last_name,
      emails: [
        {
          address: this.email,
          verified: true
        }
      ]
    };
  }
}

const casual = new Casual();

export const schema = [
  `
type Email {
  address: String
  verified: Boolean
}
type User {
  emails: [Email]
  firstName: String
  lastName: String
}
type Query {
  users(name: String): [User]
}
type Mutation {
  addUser(
    firstName: String!
    lastName: String!
  ): User
}
schema {
  query: Query
  mutation: Mutation
}
`
];

export const resolvers = {
    Query: {
      users: (root: any, args: any) =>
      {
        const data = [];
        for (let i = 0; i < 10; i++) {
          data.push(casual.user());
        }
        return data;
      },
    },
    User: {
      emails: () => casual.user().emails,
      firstName: (input: any) => input.firstName || casual_impl.first_name,
      lastName: (input: any) => input.lastName || casual_impl.last_name,
    },
    Mutation: {
      addUser: (_: any, input: any) => {
        const user = casual.user();

        user.firstName = input.firstName;
        user.lastName = input.lastName;

        return user;
      }
    }
  };
