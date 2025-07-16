import { SequelizeOptions } from 'sequelize-typescript';

const config: { [key: string]: SequelizeOptions } = {
  local: {
    username: 'postgres',
    password: 'password',
    database: 'voyage_dev',
    host: 'localhost',
    dialect: 'postgres',
  },
  development: {
    username: 'postgres',
    password: 'password',
    database: 'voyage_dev',
    host: 'localhost',
    dialect: 'postgres',
  },
  test: {
    username: 'postgres',
    password: 'password',
    database: 'voyage_test',
    host: 'localhost',
    dialect: 'postgres',
  },
  production: {
    username: 'postgres',
    password: 'password',
    database: 'voyage_prod',
    host: 'localhost',
    dialect: 'postgres',
  },
};

export default config;
