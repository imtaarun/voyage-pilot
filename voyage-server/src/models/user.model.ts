import { Model, AllowNull, AutoIncrement, Column, DataType, HasMany, PrimaryKey, Table, Unique } from "sequelize-typescript";
import { Trip } from "./trip.model";

@Table({
  tableName: 'Users',
  timestamps: true, // This will automatically add createdAt and updatedAt columns
})
export class User extends Model {
  @PrimaryKey
  @AutoIncrement
  @Column(DataType.INTEGER)
  id!: number;

  @Unique
  @AllowNull(false)
  @Column(DataType.STRING)
  username!: string;

  @Unique
  @AllowNull(false)
  @Column(DataType.STRING)
  email!: string;

  @AllowNull(false)
  @Column(DataType.STRING)
  passwordHash!: string;

  @HasMany(() => Trip)
  trips?: Trip[];
}