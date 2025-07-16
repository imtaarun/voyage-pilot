import { Model, AllowNull, AutoIncrement, Column, DataType, HasMany, PrimaryKey, Table, ForeignKey, BelongsTo } from "sequelize-typescript";
import { User } from "./user.model";
import { TripDay } from "./trip-day.model";

@Table({
  tableName: 'Trips',
  timestamps: true,
})
export class Trip extends Model {
  @PrimaryKey
  @AutoIncrement
  @Column(DataType.INTEGER)
  id!: number;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.INTEGER)
  userId!: number;

  @BelongsTo(() => User)
  user!: User;

  @AllowNull(false)
  @Column(DataType.STRING)
  name!: string;

  @Column(DataType.TEXT)
  description?: string; // Optional as it's not allowNull: false in migration

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  startDate!: string; // DATEONLY is typically represented as a string in JS

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  endDate!: string; // DATEONLY is typically represented as a string in JS

  @HasMany(() => TripDay)
  tripDays?: TripDay[];
}